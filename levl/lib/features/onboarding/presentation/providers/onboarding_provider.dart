import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/analytics/product_analytics.dart';
import '../../../../core/supabase/isar_service.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../core/supabase/supabase_service.dart';

part 'onboarding_provider.g.dart';

/// The 6 life spheres a user can develop.
class Sphere {
  final String key;
  final String label;
  final String icon;
  final String description;
  final Color color;

  const Sphere(this.key, this.label, this.icon, this.description, this.color);

  static final all = [
    const Sphere('discipline', 'Дисциплина', '⚡',
        'Привычки, режим, выполнение обязательств',
        Color(0xFF4A6FA5)),
    const Sphere('knowledge', 'Знания', '📚',
        'Обучение, навыки, профессиональный рост',
        Color(0xFF4A8C6F)),
    const Sphere('relations', 'Отношения', '🤝',
        'Семья, друзья, нетворкинг',
        Color(0xFFC47E6B)),
    const Sphere('energy', 'Энергия', '🔥',
        'Здоровье, спорт, сон, питание',
        Color(0xFFC47E2E)),
    const Sphere('will', 'Воля', '🎯',
        'Фокус, упорство, преодоление трудностей',
        Color(0xFF7B6FA5)),
    const Sphere('wisdom', 'Мудрость', '🧠',
        'Рефлексия, решения, эмоциональный интеллект',
        Color(0xFF4A8C8C)),
  ];
}

/// Immutable data collected during onboarding.
class OnboardingData {
  final String lifeContext;         // Step 1
  final String painPoints;          // Step 2
  final List<String> spheres;       // Step 3 — selected sphere keys (2-4)
  final Map<String, String> sphereGoals; // Step 4 — goal per sphere
  final String workStyle;           // Step 5
  final String mainGoal;            // Step 6
  final int dailyMinutes;           // Step 7

  const OnboardingData({
    this.lifeContext = '',
    this.painPoints = '',
    this.spheres = const [],
    this.sphereGoals = const {},
    this.workStyle = '',
    this.mainGoal = '',
    this.dailyMinutes = 30,
  });

  OnboardingData copyWith({
    String? lifeContext,
    String? painPoints,
    List<String>? spheres,
    Map<String, String>? sphereGoals,
    String? workStyle,
    String? mainGoal,
    int? dailyMinutes,
  }) {
    return OnboardingData(
      lifeContext: lifeContext ?? this.lifeContext,
      painPoints: painPoints ?? this.painPoints,
      spheres: spheres ?? this.spheres,
      sphereGoals: sphereGoals ?? this.sphereGoals,
      workStyle: workStyle ?? this.workStyle,
      mainGoal: mainGoal ?? this.mainGoal,
      dailyMinutes: dailyMinutes ?? this.dailyMinutes,
    );
  }

  /// Can proceed from a given step (0-indexed)?
  bool canProceed(int step) => switch (step) {
    0 => lifeContext.trim().length >= 3,
    1 => painPoints.isNotEmpty,
    2 => spheres.length >= 2,                          // min 2 spheres
    3 => spheres.isNotEmpty && spheres.every((s) => (sphereGoals[s] ?? '').trim().length >= 3),
    4 => workStyle.isNotEmpty,
    5 => mainGoal.trim().length >= 3,
    6 => true, // slider always has a value
    _ => true,
  };
}

@Riverpod(keepAlive: true)
class OnboardingNotifier extends _$OnboardingNotifier {
  @override
  OnboardingData build() => const OnboardingData();

  void setLifeContext(String value) =>
      state = state.copyWith(lifeContext: value);

  void setPainPoints(String value) =>
      state = state.copyWith(painPoints: value);

  void toggleSphere(String key) {
    final current = List<String>.from(state.spheres);
    if (current.contains(key)) {
      current.remove(key);
      // Also remove goal for deselected sphere
      final goals = Map<String, String>.from(state.sphereGoals)..remove(key);
      state = state.copyWith(spheres: current, sphereGoals: goals);
    } else if (current.length < 4) {
      current.add(key);
      state = state.copyWith(spheres: current);
    }
  }

  void setSphereGoal(String sphereKey, String goal) {
    final goals = Map<String, String>.from(state.sphereGoals);
    goals[sphereKey] = goal;
    state = state.copyWith(sphereGoals: goals);
  }

  void setWorkStyle(String value) =>
      state = state.copyWith(workStyle: value);

  void setMainGoal(String value) =>
      state = state.copyWith(mainGoal: value);

  void setDailyMinutes(int value) =>
      state = state.copyWith(dailyMinutes: value);

  String _buildGoalsJson() {
    final list = state.sphereGoals.entries
        .map((e) => {'sphere': e.key, 'goal': e.value})
        .toList();
    return jsonEncode(list);
  }

  /// Save profile to Isar after onboarding completes.
  /// Also syncs to Supabase (best-effort — app works offline if it fails).
  /// Returns error message on failure, null on success.
  Future<String?> saveProfile() async {
    try {
      final isar = await ref.read(isarProvider.future);
      final client = ref.read(supabaseClientProvider);
      final user = client.auth.currentUser;
      final userId = user?.id ?? 'local';
      final userName = user?.userMetadata?['full_name'] as String? ??
          user?.userMetadata?['name'] as String? ??
          user?.email?.split('@').first ??
          '';

      // Store painPoints in characterStateJson for AI context
      final characterState = jsonEncode({'painPoints': state.painPoints});

      final profile = UserProfileLocal()
        ..supabaseId = userId
        ..name = userName
        ..level = 1
        ..xp = 0
        ..currentStreak = 0
        ..dailyMinutes = state.dailyMinutes
        ..goalsJson = _buildGoalsJson()
        ..spheresJson = state.spheres.join(',')
        ..lifeContext = state.lifeContext
        ..mainGoal = state.mainGoal
        ..workStyle = state.workStyle
        ..characterStateJson = characterState
        ..statDiscipline = 0
        ..statKnowledge = 0
        ..statRelations = 0
        ..statEnergy = 0
        ..statWill = 0
        ..statWisdom = 0;

      // 1. Save locally first — app works even without internet
      await isar.writeTxn(() async {
        await isar.userProfileLocals.put(profile);
      });

      // 2. Sync to Supabase (best-effort — don't block on failure)
      if (userId != 'local') {
        _syncProfileToSupabase(client, userId, userName);
      }

      unawaited(
        ref.read(productAnalyticsProvider).track(
          ProductEvent.onboardingCompleted,
          properties: {
            'daily_minutes': state.dailyMinutes,
            'spheres_count': state.spheres.length,
            'goals_count': state.sphereGoals.length,
          },
        ),
      );

      return null;
    } catch (e) {
      return 'Не удалось сохранить: $e';
    }
  }

  /// Fire-and-forget Supabase sync. Failures are silent — Isar is source of truth.
  void _syncProfileToSupabase(dynamic client, String userId, String userName) {
    Future(() async {
      try {
        final goals = state.sphereGoals.entries
            .map((e) => '${e.key}: ${e.value}')
            .toList();

        await client.from('profiles').upsert({
          'id': userId,
          'name': userName,
          'life_context': state.lifeContext,
          'main_goal': state.mainGoal,
          'work_style': state.workStyle,
          'daily_minutes': state.dailyMinutes,
          'goals': goals,
          'spheres': state.spheres,
          'pain_points': state.painPoints,
          'level': 1,
          'xp': 0,
          'current_streak': 0,
        });
      } catch (_) {
        // Offline or Supabase not configured — Isar has the data
      }
    });
  }
}

/// Has the user completed onboarding? Check if profile exists in Isar.
@Riverpod(keepAlive: true)
class OnboardingComplete extends _$OnboardingComplete {
  @override
  Future<bool> build() async {
    final isar = await ref.watch(isarProvider.future);
    final count = await isar.userProfileLocals.count();
    return count > 0;
  }

  void markComplete() {
    state = const AsyncData(true);
  }
}
