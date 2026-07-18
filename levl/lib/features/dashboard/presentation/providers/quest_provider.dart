import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/audio/audio_service.dart';
import '../../../../core/supabase/isar_service.dart';
import '../../../../core/supabase/supabase_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../shared/models/quest_model.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/providers/level_up_provider.dart';
import '../../../../core/notifications/notification_service.dart';

part 'quest_provider.g.dart';

enum QuestFeedbackReason {
  tooHard('too_hard'),
  notRelevant('not_relevant'),
  noTime('no_time');

  final String value;
  const QuestFeedbackReason(this.value);
}

/// Helper: run a filtered Isar query by building it explicitly.
Future<List<QuestLocal>> _questQuery(
  Isar isar,
  QueryBuilder<QuestLocal, QuestLocal, QAfterFilterCondition> filtered,
) async {
  return filtered.build().findAll();
}

Future<QuestLocal?> _questQueryFirst(
  QueryBuilder<QuestLocal, QuestLocal, QAfterFilterCondition> filtered,
) async {
  return filtered.build().findFirst();
}

@Riverpod(keepAlive: true)
class QuestNotifier extends _$QuestNotifier {
  @override
  AsyncValue<List<Quest>> build() {
    _checkAndUpdateStreak();
    _loadTodayQuests();
    _scheduleNotifications();
    return const AsyncLoading();
  }

  /// Build profile context from Isar to send to Edge Functions as fallback.
  Future<Map<String, dynamic>> _buildUserContext() async {
    try {
      final isar = await ref.read(isarProvider.future);
      final profiles = await isar.userProfileLocals.where().findAll();
      final profile = profiles.firstOrNull;
      if (profile == null) return {};

      List<dynamic> goals = [];
      try {
        if (profile.goalsJson.isNotEmpty) {
          goals = jsonDecode(profile.goalsJson) as List;
        }
      } catch (_) {}

      Map<String, dynamic> characterState = {};
      try {
        if (profile.characterStateJson.isNotEmpty) {
          characterState =
              jsonDecode(profile.characterStateJson) as Map<String, dynamic>;
        }
      } catch (_) {}

      return {
        'name': profile.name,
        'level': profile.level,
        'xp': profile.xp,
        'streak': profile.currentStreak,
        'mainGoal': profile.mainGoal,
        'lifeContext': profile.lifeContext,
        'workStyle': profile.workStyle,
        'dailyMinutes': profile.dailyMinutes,
        'spheres': profile.spheresJson,
        'goals': goals,
        'painPoints': characterState['painPoints'] ?? '',
      };
    } catch (_) {
      return {};
    }
  }

  /// Streak logic: increment if opened day after last visit, reset if skipped days.
  Future<void> _checkAndUpdateStreak() async {
    try {
      final isar = await ref.read(isarProvider.future);
      final profiles = await isar.userProfileLocals.where().build().findAll();
      final profile = profiles.firstOrNull;
      if (profile == null) return;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final lastActive = profile.lastActiveDate;

      if (lastActive == null) {
        profile.currentStreak = 1;
      } else {
        final lastDay = DateTime(
          lastActive.year,
          lastActive.month,
          lastActive.day,
        );
        final diff = today.difference(lastDay).inDays;
        if (diff == 0) return; // already checked in today
        if (diff == 1) {
          profile.currentStreak += 1; // consecutive day
        } else {
          profile.currentStreak = 1; // missed days — reset
        }
      }

      profile.lastActiveDate = now;
      await isar.writeTxn(() async {
        await isar.userProfileLocals.put(profile);
      });
      ref.invalidate(userProfileNotifierProvider);
    } catch (_) {}
  }

  /// Schedule/reschedule notifications on app open.
  Future<void> _scheduleNotifications() async {
    try {
      final isar = await ref.read(isarProvider.future);
      final profiles = await isar.userProfileLocals.where().build().findAll();
      final profile = profiles.firstOrNull;
      if (profile == null) return;

      // Cancel return-after-absence (user is here now)
      await NotificationService.instance.cancelReturn();

      // Reschedule all based on current profile
      await NotificationService.instance.scheduleAll(
        dailyMinutes: profile.dailyMinutes,
        currentStreak: profile.currentStreak,
      );
    } catch (_) {}
  }

  /// Load today's quests: try Isar cache first, then Edge Function
  Future<void> _loadTodayQuests() async {
    try {
      final isar = await ref.read(isarProvider.future);
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      // Check local cache (Isar) for today's quests
      final cached = await _questQuery(
        isar,
        isar.questLocals.filter().createdAtGreaterThan(
          startOfDay,
          include: true,
        ),
      );

      if (cached.isNotEmpty) {
        state = AsyncData(_localToQuests(cached));
        return;
      }

      // No local cache → call Edge Function
      await fetchFromEdgeFunction();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Call Supabase Edge Function to generate quests
  Future<void> fetchFromEdgeFunction() async {
    state = const AsyncLoading();
    try {
      final client = ref.read(supabaseClientProvider);
      final session = await ref
          .read(authNotifierProvider.notifier)
          .ensureRemoteSession();
      if (session == null) {
        throw const AuthException('Не удалось восстановить гостевую сессию');
      }

      // Build profile context from Isar — Edge Function uses it if Supabase profile is missing
      final userContext = await _buildUserContext();

      final response = await client.functions.invoke(
        'generate-quests',
        method: HttpMethod.post,
        body: userContext.isNotEmpty ? {'userContext': userContext} : null,
      );

      final data = response.data as Map<String, dynamic>;
      final questsJson = data['quests'] as List<dynamic>;
      final userId = client.auth.currentUser?.id ?? 'local';

      final quests = questsJson.asMap().entries.map((entry) {
        return Quest.fromEdgeFunction(
          entry.value as Map<String, dynamic>,
          entry.key.toString(),
          userId,
        );
      }).toList();

      // Save to Isar for offline access
      await _saveToIsar(quests);

      state = AsyncData(quests);
    } catch (e, st) {
      // If Edge Function fails, try to show any cached quests
      final isar = await ref.read(isarProvider.future);
      final allCached = await _questQuery(
        isar,
        isar.questLocals.filter().statusEqualTo(QuestStatus.pending),
      );
      // Take last 3
      final recent = allCached.length > 3
          ? allCached.sublist(allCached.length - 3)
          : allCached;

      if (recent.isNotEmpty) {
        state = AsyncData(_localToQuests(recent));
      } else {
        state = AsyncError(e, st);
      }
    }
  }

  /// Start a timer-backed verification and persist it across app restarts.
  Future<bool> startQuestVerification(String questId) async {
    final current = state.valueOrNull ?? [];
    final questIndex = current.indexWhere((q) => q.id == questId);
    if (questIndex == -1) return false;

    final quest = current[questIndex];
    if (quest.status != QuestStatus.pending ||
        quest.verificationType != QuestVerificationType.timer) {
      return false;
    }
    if (quest.verificationStatus == QuestVerificationStatus.inProgress) {
      return true;
    }

    final startedAt = DateTime.now();
    final started = quest.copyWith(
      verificationStatus: QuestVerificationStatus.inProgress,
      verificationStartedAt: startedAt,
    );
    final updated = [...current];
    updated[questIndex] = started;
    state = AsyncData(updated);

    final isar = await ref.read(isarProvider.future);
    final local = await _questQueryFirst(
      isar.questLocals.filter().supabaseIdEqualTo(questId),
    );
    if (local != null) {
      local.verificationStatus = QuestVerificationStatus.inProgress;
      local.verificationStartedAt = startedAt;
      await isar.writeTxn(() async {
        await isar.questLocals.put(local);
      });
    }

    _syncVerificationStart(questId, startedAt);
    return true;
  }

  /// Mark a verified quest as completed and add XP.
  Future<bool> completeQuest(String questId) async {
    final current = state.valueOrNull ?? [];
    final questIndex = current.indexWhere((q) => q.id == questId);
    if (questIndex == -1) return false;

    final quest = current[questIndex];
    final now = DateTime.now();
    if (quest.status != QuestStatus.pending ||
        !quest.verificationReadyAt(now)) {
      return false;
    }

    final verifiedAt = now;
    final completed = quest.copyWith(
      status: QuestStatus.completed,
      completedAt: verifiedAt,
      verificationStatus: QuestVerificationStatus.verified,
      verifiedAt: verifiedAt,
    );

    // Update UI immediately
    final updated = [...current];
    updated[questIndex] = completed;
    state = AsyncData(updated);

    // Update Isar
    final isar = await ref.read(isarProvider.future);
    final local = await _questQueryFirst(
      isar.questLocals.filter().supabaseIdEqualTo(questId),
    );

    if (local != null) {
      local.status = QuestStatus.completed;
      local.completedAt = verifiedAt;
      local.verificationStatus = QuestVerificationStatus.verified;
      local.verifiedAt = verifiedAt;
      await isar.writeTxn(() async {
        await isar.questLocals.put(local);
      });
    }

    // Add XP to profile + update sphere stat
    await _addXpToProfile(quest.xpReward, quest.category);

    // Cancel streak-at-risk notification (quest done today)
    NotificationService.instance.cancelStreakAlert();

    // Update Supabase (best effort, don't block UI)
    _syncCompletionToSupabase(questId, quest.xpReward, verifiedAt);
    return true;
  }

  /// Remove an unsuitable quest from today and remember why it failed.
  Future<void> skipQuest(String questId, QuestFeedbackReason reason) async {
    final current = state.valueOrNull ?? [];
    final questIndex = current.indexWhere((q) => q.id == questId);
    if (questIndex == -1) return;

    final quest = current[questIndex];
    if (quest.status != QuestStatus.pending) return;

    final updated = [...current];
    updated[questIndex] = quest.copyWith(status: QuestStatus.skipped);
    state = AsyncData(updated);

    final isar = await ref.read(isarProvider.future);
    final local = await _questQueryFirst(
      isar.questLocals.filter().supabaseIdEqualTo(questId),
    );
    if (local != null) {
      local.status = QuestStatus.skipped;
      await isar.writeTxn(() async {
        await isar.questLocals.put(local);
      });
    }

    _syncFeedbackToSupabase(questId, reason);
  }

  Future<void> _addXpToProfile(int xp, QuestCategory category) async {
    final isar = await ref.read(isarProvider.future);
    final profiles = await isar.userProfileLocals.where().build().findAll();
    final profile = profiles.firstOrNull;
    if (profile == null) return;

    final oldLevel = profile.level;

    profile.xp += xp;
    profile.level = levelFromXp(profile.xp);
    profile.lastActiveDate = DateTime.now();

    // Grow sphere XP — gain = xp / 3, uncapped (accumulates indefinitely)
    final gain = (xp / 3).round().clamp(3, 67);
    switch (category) {
      case QuestCategory.discipline:
        profile.statDiscipline += gain;
      case QuestCategory.knowledge:
        profile.statKnowledge += gain;
      case QuestCategory.relations:
        profile.statRelations += gain;
      case QuestCategory.energy:
        profile.statEnergy += gain;
      case QuestCategory.will:
        profile.statWill += gain;
      case QuestCategory.wisdom:
        profile.statWisdom += gain;
    }

    await isar.writeTxn(() async {
      await isar.userProfileLocals.put(profile);
    });

    // Invalidate user provider so UI updates
    ref.invalidate(userProfileNotifierProvider);

    // Level-up event
    if (profile.level > oldLevel) {
      HapticFeedback.heavyImpact();
      ref.read(audioServiceProvider).playLevelUp();
      ref.read(levelUpNotifierProvider.notifier).trigger(profile.level);
    }
  }

  Future<void> _syncVerificationStart(
    String questId,
    DateTime startedAt,
  ) async {
    try {
      final client = ref.read(supabaseClientProvider);
      await client
          .from('quests')
          .update({
            'verification_status': 'in_progress',
            'verification_started_at': startedAt.toUtc().toIso8601String(),
          })
          .eq('id', questId);
    } catch (_) {
      // Local verification remains active if remote sync fails.
    }
  }

  Future<void> _syncCompletionToSupabase(
    String questId,
    int xp,
    DateTime verifiedAt,
  ) async {
    try {
      final client = ref.read(supabaseClientProvider);
      await client
          .from('quests')
          .update({
            'status': 'completed',
            'completed_at': verifiedAt.toUtc().toIso8601String(),
            'verification_status': 'verified',
            'verified_at': verifiedAt.toUtc().toIso8601String(),
          })
          .eq('id', questId);

      final uid = client.auth.currentUser?.id;
      if (uid != null) {
        await client.rpc('add_xp', params: {'user_id': uid, 'xp_amount': xp});
      }
    } catch (_) {
      // Offline — will sync later
    }
  }

  Future<void> _syncFeedbackToSupabase(
    String questId,
    QuestFeedbackReason reason,
  ) async {
    try {
      final client = ref.read(supabaseClientProvider);
      final uid = client.auth.currentUser?.id;
      if (uid == null) return;

      await client
          .from('quests')
          .update({'status': 'skipped'})
          .eq('id', questId);

      await client.from('quest_feedback').upsert({
        'quest_id': questId,
        'user_id': uid,
        'reason': reason.value,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (_) {
      // The local skip remains valid if remote sync fails.
    }
  }

  Future<void> _saveToIsar(List<Quest> quests) async {
    final isar = await ref.read(isarProvider.future);
    await isar.writeTxn(() async {
      for (final q in quests) {
        final local = QuestLocal()
          ..supabaseId = q.id
          ..userId = q.userId
          ..title = q.title
          ..description = q.description
          ..tip = q.tip
          ..xpReward = q.xpReward
          ..estimatedMinutes = q.estimatedMinutes
          ..isMainGoalTask = q.isMainGoalTask
          ..successCriterion = q.successCriterion
          ..verificationType = q.verificationType
          ..verificationStatus = q.verificationStatus
          ..verificationStartedAt = q.verificationStartedAt
          ..verifiedAt = q.verifiedAt
          ..status = q.status
          ..difficulty = q.difficulty
          ..type = q.type
          ..category = q.category
          ..createdAt = q.createdAt;
        await isar.questLocals.put(local);
      }
    });
  }

  List<Quest> _localToQuests(List<QuestLocal> locals) {
    return locals
        .map(
          (l) => Quest(
            id: l.supabaseId,
            userId: l.userId,
            title: l.title,
            description: l.description,
            tip: l.tip,
            xpReward: l.xpReward,
            estimatedMinutes: l.estimatedMinutes,
            isMainGoalTask: l.isMainGoalTask,
            successCriterion: l.successCriterion,
            verificationType: l.verificationType,
            verificationStatus: l.verificationStatus,
            verificationStartedAt: l.verificationStartedAt,
            verifiedAt: l.verifiedAt,
            status: l.status,
            difficulty: l.difficulty,
            type: l.type,
            category: l.category,
            createdAt: l.createdAt,
            completedAt: l.completedAt,
          ),
        )
        .toList();
  }
}

/// User profile from Isar for dashboard display
@Riverpod(keepAlive: true)
class UserProfileNotifier extends _$UserProfileNotifier {
  @override
  Future<UserProfile> build() async {
    final isar = await ref.watch(isarProvider.future);
    final profiles = await isar.userProfileLocals.where().build().findAll();
    final local = profiles.firstOrNull;
    if (local == null) {
      return const UserProfile(id: 'empty', name: 'Путник');
    }

    // Parse goals
    List<String> goals = [];
    try {
      if (local.goalsJson.isNotEmpty) {
        final parsed = jsonDecode(local.goalsJson) as List;
        goals = parsed.map((g) => g['goal']?.toString() ?? '').toList();
      }
    } catch (_) {}

    // Count total completed quests for achievements
    final questsCompleted = await isar.questLocals
        .filter()
        .statusEqualTo(QuestStatus.completed)
        .build()
        .count();

    return UserProfile(
      id: local.supabaseId,
      name: local.name,
      level: local.level,
      xp: local.xp,
      currentStreak: local.currentStreak,
      questsCompleted: questsCompleted,
      dailyMinutes: local.dailyMinutes,
      goals: goals,
      lifeContext: local.lifeContext,
      mainGoal: local.mainGoal,
      workStyle: local.workStyle,
      stats: CharacterStats(
        discipline: local.statDiscipline,
        knowledge: local.statKnowledge,
        relations: local.statRelations,
        energy: local.statEnergy,
        will: local.statWill,
        wisdom: local.statWisdom,
      ),
      characterStateJson: local.characterStateJson,
    );
  }
}
