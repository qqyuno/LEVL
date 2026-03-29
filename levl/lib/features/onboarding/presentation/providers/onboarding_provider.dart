import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/supabase/isar_service.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../core/supabase/supabase_service.dart';

part 'onboarding_provider.g.dart';

/// Immutable data collected during onboarding.
class OnboardingData {
  final String lifeContext;    // Step 1
  final String painPoints;     // Step 2
  final String workStyle;      // Step 3
  final String mainGoal;       // Step 4
  final int dailyMinutes;      // Step 5

  const OnboardingData({
    this.lifeContext = '',
    this.painPoints = '',
    this.workStyle = '',
    this.mainGoal = '',
    this.dailyMinutes = 30,
  });

  OnboardingData copyWith({
    String? lifeContext,
    String? painPoints,
    String? workStyle,
    String? mainGoal,
    int? dailyMinutes,
  }) {
    return OnboardingData(
      lifeContext: lifeContext ?? this.lifeContext,
      painPoints: painPoints ?? this.painPoints,
      workStyle: workStyle ?? this.workStyle,
      mainGoal: mainGoal ?? this.mainGoal,
      dailyMinutes: dailyMinutes ?? this.dailyMinutes,
    );
  }

  /// Can proceed from a given step (0-indexed)?
  bool canProceed(int step) => switch (step) {
    0 => lifeContext.trim().length >= 3,
    1 => painPoints.isNotEmpty,
    2 => workStyle.isNotEmpty,
    3 => mainGoal.trim().length >= 3,
    4 => true, // slider always has a value
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

  void setWorkStyle(String value) =>
      state = state.copyWith(workStyle: value);

  void setMainGoal(String value) =>
      state = state.copyWith(mainGoal: value);

  void setDailyMinutes(int value) =>
      state = state.copyWith(dailyMinutes: value);

  /// Save profile to Isar after onboarding completes.
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

      final profile = UserProfileLocal()
        ..supabaseId = userId
        ..name = userName
        ..level = 1
        ..xp = 0
        ..currentStreak = 0
        ..dailyMinutes = state.dailyMinutes
        ..goalsJson = '[]'
        ..lifeContext = state.lifeContext
        ..mainGoal = state.mainGoal
        ..workStyle = state.workStyle
        ..characterStateJson = '{}'
        ..statDiscipline = 10
        ..statKnowledge = 10
        ..statRelations = 10
        ..statEnergy = 10
        ..statWill = 10
        ..statWisdom = 10;

      await isar.writeTxn(() async {
        await isar.userProfileLocals.put(profile);
      });
      return null;
    } catch (e) {
      return 'Не удалось сохранить: $e';
    }
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
