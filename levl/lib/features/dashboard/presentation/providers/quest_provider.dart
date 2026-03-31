import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/audio/audio_service.dart';
import '../../../../core/supabase/isar_service.dart';
import '../../../../core/supabase/supabase_service.dart';
import '../../../../shared/models/quest_model.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/providers/level_up_provider.dart';

part 'quest_provider.g.dart';

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
    _loadTodayQuests();
    return const AsyncLoading();
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
        isar.questLocals.filter().createdAtGreaterThan(startOfDay, include: false),
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
      final response = await client.functions.invoke(
        'generate-quests',
        method: HttpMethod.post,
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
      final recent = allCached.length > 3 ? allCached.sublist(allCached.length - 3) : allCached;

      if (recent.isNotEmpty) {
        state = AsyncData(_localToQuests(recent));
      } else {
        state = AsyncError(e, st);
      }
    }
  }

  /// Mark a quest as completed, add XP
  Future<void> completeQuest(String questId) async {
    final current = state.valueOrNull ?? [];
    final questIndex = current.indexWhere((q) => q.id == questId);
    if (questIndex == -1) return;

    final quest = current[questIndex];
    if (quest.status == QuestStatus.completed) return;

    final completed = quest.copyWith(
      status: QuestStatus.completed,
      completedAt: DateTime.now(),
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
      local.completedAt = DateTime.now();
      await isar.writeTxn(() async {
        await isar.questLocals.put(local);
      });
    }

    // Add XP to profile
    await _addXpToProfile(quest.xpReward);

    // Update Supabase (best effort, don't block UI)
    _syncCompletionToSupabase(questId, quest.xpReward);
  }

  Future<void> _addXpToProfile(int xp) async {
    final isar = await ref.read(isarProvider.future);
    final profiles = await isar.userProfileLocals.where().build().findAll();
    final profile = profiles.firstOrNull;
    if (profile == null) return;

    final oldLevel = profile.level;

    profile.xp += xp;
    profile.level = (profile.xp ~/ 100) + 1;
    profile.lastActiveDate = DateTime.now();

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

  Future<void> _syncCompletionToSupabase(String questId, int xp) async {
    try {
      final client = ref.read(supabaseClientProvider);
      await client.from('quests').update({
        'status': 'completed',
        'completed_at': DateTime.now().toIso8601String(),
      }).eq('id', questId);

      await client.rpc('add_xp', params: {
        'user_id': client.auth.currentUser!.id,
        'xp_amount': xp,
      });
    } catch (_) {
      // Offline — will sync later
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
    return locals.map((l) => Quest(
      id: l.supabaseId,
      userId: l.userId,
      title: l.title,
      description: l.description,
      tip: l.tip,
      xpReward: l.xpReward,
      estimatedMinutes: l.estimatedMinutes,
      isMainGoalTask: l.isMainGoalTask,
      status: l.status,
      difficulty: l.difficulty,
      type: l.type,
      category: l.category,
      createdAt: l.createdAt,
      completedAt: l.completedAt,
    )).toList();
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

    return UserProfile(
      id: local.supabaseId,
      name: local.name,
      level: local.level,
      xp: local.xp,
      currentStreak: local.currentStreak,
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
    );
  }
}
