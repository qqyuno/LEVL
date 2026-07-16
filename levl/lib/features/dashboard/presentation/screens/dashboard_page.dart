import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/audio/audio_service.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/avatar_config.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/models/quest_model.dart';
import '../../../../shared/widgets/premium_face_avatar_widget.dart';
import '../providers/quest_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileNotifierProvider);
    final questsAsync = ref.watch(questNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: userAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.gold),
          ),
          error: (e, _) => Center(child: Text('Ошибка: $e')),
          data: (user) => CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _DashboardHeader(user: user)),
              SliverToBoxAdapter(child: _HeroSegment(user: user)),
              SliverToBoxAdapter(
                child: questsAsync.when(
                  loading: () => _SystemCommandCenter(
                    user: user,
                    quests: const [],
                    isLoading: true,
                    onComplete: (_) {},
                  ),
                  error: (_, __) => _SystemCommandCenter(
                    user: user,
                    quests: const [],
                    hasQuestError: true,
                    onComplete: (_) {},
                  ),
                  data: (quests) => _SystemCommandCenter(
                    user: user,
                    quests: quests,
                    onComplete: (quest) async {
                      final confirmed = await _showQuestVerification(
                        context,
                        quest,
                      );
                      if (!confirmed) return;
                      await ref
                          .read(questNotifierProvider.notifier)
                          .completeQuest(quest.id);
                    },
                  ),
                ),
              ),

              // Main Quest
              SliverToBoxAdapter(
                child: questsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.gold),
                    ),
                  ),
                  error: (e, _) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: _ErrorCard(
                      message: 'Не удалось загрузить задания',
                      onRetry: () => ref
                          .read(questNotifierProvider.notifier)
                          .fetchFromEdgeFunction(),
                    ),
                  ),
                  data: (quests) {
                    final mainQuest = quests
                        .where(
                          (q) =>
                              q.isMainGoalTask &&
                              q.status != QuestStatus.skipped,
                        )
                        .firstOrNull;
                    if (mainQuest == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: _MainQuestCard(
                        quest: mainQuest,
                        onComplete: () => ref
                            .read(questNotifierProvider.notifier)
                            .completeQuest(mainQuest.id),
                      ),
                    );
                  },
                ),
              ),

              // Section label
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: Text(
                    'ЗАДАЧИ ДНЯ',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),

              // Daily Quests
              questsAsync.when(
                loading: () =>
                    const SliverToBoxAdapter(child: SizedBox.shrink()),
                error: (_, __) =>
                    const SliverToBoxAdapter(child: SizedBox.shrink()),
                data: (quests) {
                  final nextQuest = quests
                      .where(
                        (q) =>
                            !q.isMainGoalTask &&
                            q.status == QuestStatus.pending,
                      )
                      .firstOrNull;
                  final daily = quests
                      .where(
                        (q) =>
                            !q.isMainGoalTask &&
                            q.id != nextQuest?.id &&
                            q.status != QuestStatus.skipped,
                      )
                      .toList();
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _QuestCard(
                            quest: daily[index],
                            onComplete: () => ref
                                .read(questNotifierProvider.notifier)
                                .completeQuest(daily[index].id),
                          ),
                        ),
                        childCount: daily.length,
                      ),
                    ),
                  );
                },
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header: уровень + суперцель + streak с пульсом
// ---------------------------------------------------------------------------
class _DashboardHeader extends StatefulWidget {
  final UserProfile user;
  const _DashboardHeader({required this.user});

  @override
  State<_DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<_DashboardHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  bool _pulseScheduled = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scale = Tween(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_pulseScheduled || widget.user.currentStreak <= 0) return;
    _pulseScheduled = true;
    if (!MediaQuery.disableAnimationsOf(context)) {
      Future.delayed(const Duration(milliseconds: 600), _pulseTwice);
    }
  }

  Future<void> _pulseTwice() async {
    if (!mounted) return;
    await _ctrl.forward();
    await _ctrl.reverse();
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    await _ctrl.forward();
    await _ctrl.reverse();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'УРОВЕНЬ ${widget.user.level}',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.user.mainGoal.isNotEmpty
                      ? widget.user.mainGoal
                      : 'Путь начинается',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Streak badge с пульсом
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RepaintBoundary(
                      child: ScaleTransition(
                        scale: _scale,
                        child: const Icon(
                          Icons.local_fire_department,
                          color: AppColors.warning,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.user.currentStreak}',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Settings gear
              GestureDetector(
                onTap: () => context.push(AppRoutes.notificationSettings),
                child: const Icon(
                  Icons.settings_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hero: аватар + анимированный XP bar
// ---------------------------------------------------------------------------
class _HeroSegment extends StatelessWidget {
  final UserProfile user;
  const _HeroSegment({required this.user});

  @override
  Widget build(BuildContext context) {
    final progress = levelProgress(user.xp, user.level);
    final xpInLevel = xpInCurrentLevel(user.xp, user.level);
    final xpToNext = xpToNextLevel(user.level) - xpInLevel;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Row(
            children: [
              PremiumFaceAvatarWidget(
                config: user.characterStateJson.isNotEmpty
                    ? AvatarConfig.fromJsonString(user.characterStateJson)
                    : const AvatarConfig(),
                size: 146,
                level: user.level,
                streak: user.currentStreak,
              ),
              const SizedBox(width: 22),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'СЕГОДНЯ',
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user.name.isEmpty ? 'Твой день' : user.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 25,
                        color: AppColors.textPrimary,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      user.mainGoal.isEmpty
                          ? 'Система собирает твой первый ориентир.'
                          : user.mainGoal,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Text(
                          '${user.xp} XP',
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$xpToNext до уровня ${user.level + 1}',
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: AppColors.textDisabled,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: Stack(
                        children: [
                          Container(height: 5, color: AppColors.divider),
                          FractionallySizedBox(
                            widthFactor: progress.clamp(0.0, 1.0),
                            child: Container(height: 5, color: AppColors.gold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Подтверждение от Системы перед завершением задания
// ---------------------------------------------------------------------------
class _SystemCommandCenter extends StatelessWidget {
  final UserProfile user;
  final List<Quest> quests;
  final bool isLoading;
  final bool hasQuestError;
  final ValueChanged<Quest> onComplete;

  const _SystemCommandCenter({
    required this.user,
    required this.quests,
    required this.onComplete,
    this.isLoading = false,
    this.hasQuestError = false,
  });

  @override
  Widget build(BuildContext context) {
    final dailyQuests = quests
        .where(
          (quest) =>
              !quest.isMainGoalTask && quest.status != QuestStatus.skipped,
        )
        .toList();
    final nextQuest = dailyQuests
        .where((quest) => quest.status == QuestStatus.pending)
        .firstOrNull;
    final completed = dailyQuests
        .where((quest) => quest.status == QuestStatus.completed)
        .length;
    final total = dailyQuests.isEmpty ? 3 : dailyQuests.length;
    final completion = total == 0 ? 0.0 : completed / total;
    final headline = nextQuest?.title ?? _headline(completed, total);
    final note = nextQuest?.description.isNotEmpty == true
        ? nextQuest!.description
        : _note(completed, total);
    final verificationInProgress =
        nextQuest?.verificationStatus == QuestVerificationStatus.inProgress;
    var actionLabel = 'Открыть Систему';
    var actionIcon = Icons.auto_awesome;
    if (nextQuest != null) {
      actionLabel = verificationInProgress
          ? 'Продолжить проверку'
          : 'Открыть проверку';
      actionIcon = verificationInProgress
          ? Icons.timer_outlined
          : nextQuest.verificationType.icon;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'СЛЕДУЮЩИЙ ШАГ',
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDisabled,
                    letterSpacing: 2,
                  ),
                ),
                const Spacer(),
                _PulseBadge(
                  label: isLoading
                      ? 'СБОР'
                      : hasQuestError
                      ? 'ОФЛАЙН'
                      : '$completed/$total · ${user.currentStreak} ДН.',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              headline,
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 24,
                color: AppColors.textPrimary,
                height: 1.12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              note,
              style: GoogleFonts.dmSans(
                fontSize: 13.5,
                color: AppColors.textSecondary,
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _SystemMetric(
                    label: 'ВРЕМЯ',
                    value: nextQuest == null
                        ? '${user.dailyMinutes} мин'
                        : '${nextQuest.estimatedMinutes} мин',
                    icon: Icons.timer_outlined,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SystemMetric(
                    label: 'НАГРАДА',
                    value: nextQuest == null
                        ? 'Ритм дня'
                        : '+${nextQuest.xpReward} XP',
                    icon: Icons.bolt_rounded,
                    color: AppColors.sphereKnowledge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _DailyProgressBar(
              completed: completed,
              total: total,
              completion: completion,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: nextQuest == null
                  ? () => context.go(AppRoutes.aiMentor)
                  : () => onComplete(nextQuest),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(actionIcon, size: 17, color: AppColors.surface),
                    const SizedBox(width: 8),
                    Text(
                      actionLabel,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.surface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _headline(int completed, int total) {
    if (hasQuestError) return 'Путь сохранён локально.';
    if (isLoading) return 'Система собирает день.';
    if (completed == 0) return 'Сегодня достаточно начать.';
    if (completed < total) return 'Система видит движение.';
    return 'День зафиксирован.';
  }

  String _note(int completed, int total) {
    if (hasQuestError) {
      return 'Даже без сети твой прогресс остаётся здесь. Продолжай короткими шагами.';
    }
    if (isLoading) {
      return 'Сейчас появятся три действия под твою цель и текущий ресурс.';
    }
    if (completed == 0) {
      return user.dailyMinutes <= 30
          ? 'Короткий день. Три действия без перегруза — этого достаточно.'
          : 'Фокус уже выбран. Осталось сделать первый шаг и включить движение.';
    }
    if (completed < total) {
      return 'Не разгоняй хаос. Просто закрой следующий шаг и верни контроль дню.';
    }
    return 'Все действия закрыты. Сегодня ты не просто планировал — ты двигался.';
  }
}

class _PulseBadge extends StatelessWidget {
  final String label;
  const _PulseBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _SystemMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SystemMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDisabled,
                  letterSpacing: 1.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyProgressBar extends StatelessWidget {
  final int completed;
  final int total;
  final double completion;

  const _DailyProgressBar({
    required this.completed,
    required this.total,
    required this.completion,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'ПРОГРЕСС ДНЯ',
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.textDisabled,
                letterSpacing: 1.5,
              ),
            ),
            const Spacer(),
            Text(
              '$completed из $total',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.gold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Stack(
            children: [
              Container(height: 6, color: AppColors.divider),
              FractionallySizedBox(
                widthFactor: completion.clamp(0.0, 1.0),
                child: Container(height: 6, color: AppColors.gold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Future<bool> _showQuestVerification(BuildContext context, Quest quest) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    isScrollControlled: true,
    builder: (_) => _QuestVerificationPanel(initialQuest: quest),
  );
  return result ?? false;
}

class _QuestVerificationPanel extends ConsumerStatefulWidget {
  final Quest initialQuest;

  const _QuestVerificationPanel({required this.initialQuest});

  @override
  ConsumerState<_QuestVerificationPanel> createState() =>
      _QuestVerificationPanelState();
}

class _QuestVerificationPanelState
    extends ConsumerState<_QuestVerificationPanel> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    if (widget.initialQuest.verificationType == QuestVerificationType.timer) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Quest _currentQuest() {
    final quests = ref.watch(questNotifierProvider).valueOrNull ?? const [];
    for (final quest in quests) {
      if (quest.id == widget.initialQuest.id) return quest;
    }
    return widget.initialQuest;
  }

  @override
  Widget build(BuildContext context) {
    final quest = _currentQuest();
    final now = DateTime.now();
    final remaining = quest.verificationRemainingAt(now);
    final isTimer = quest.verificationType == QuestVerificationType.timer;
    final isRunning =
        quest.verificationStatus == QuestVerificationStatus.inProgress &&
        remaining > Duration.zero;
    final isReady = quest.verificationReadyAt(now);

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'ПРОВЕРКА СИСТЕМЫ',
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gold,
                      letterSpacing: 2,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Закрыть',
                    onPressed: () => Navigator.pop(context, false),
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
                ],
              ),
              Text(
                quest.title,
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 24,
                  height: 1.15,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _SuccessCriterion(quest: quest),
              const SizedBox(height: 22),
              if (!isTimer)
                _SelfConfirmationBody(
                  onConfirm: () => Navigator.pop(context, true),
                )
              else if (quest.verificationStatus ==
                  QuestVerificationStatus.notStarted)
                _TimerStartBody(
                  minutes: quest.estimatedMinutes,
                  onStart: () async {
                    HapticFeedback.mediumImpact();
                    await ref
                        .read(questNotifierProvider.notifier)
                        .startQuestVerification(quest.id);
                  },
                )
              else
                _TimerProgressBody(
                  quest: quest,
                  remaining: remaining,
                  isRunning: isRunning,
                  isReady: isReady,
                  onConfirm: () => Navigator.pop(context, true),
                ),
              const SizedBox(height: 14),
              Center(
                child: Text(
                  'XP начислится только после подтверждения результата',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: AppColors.textDisabled,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessCriterion extends StatelessWidget {
  final Quest quest;

  const _SuccessCriterion({required this.quest});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.flag_outlined, size: 18, color: AppColors.gold),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ГОТОВО, КОГДА',
                  style: GoogleFonts.dmSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDisabled,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  quest.effectiveSuccessCriterion,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SelfConfirmationBody extends StatelessWidget {
  final VoidCallback onConfirm;

  const _SelfConfirmationBody({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Icons.verified_outlined,
          size: 42,
          color: AppColors.textPrimary,
        ),
        const SizedBox(height: 10),
        Text(
          'Результат действительно готов?',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Система доверяет тебе. Подтверди только завершённое действие.',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            height: 1.4,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 18),
        _VerificationPrimaryButton(
          label: 'Подтвердить результат',
          icon: Icons.check_rounded,
          onPressed: onConfirm,
        ),
      ],
    );
  }
}

class _TimerStartBody extends StatelessWidget {
  final int minutes;
  final VoidCallback onStart;

  const _TimerStartBody({required this.minutes, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Icons.timer_outlined,
          size: 46,
          color: AppColors.textPrimary,
        ),
        const SizedBox(height: 10),
        Text(
          '$minutes минут фокуса',
          style: GoogleFonts.dmSans(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Таймер сохранится, даже если приложение будет свёрнуто.',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            height: 1.4,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 18),
        _VerificationPrimaryButton(
          label: 'Начать',
          icon: Icons.play_arrow_rounded,
          onPressed: onStart,
        ),
      ],
    );
  }
}

class _TimerProgressBody extends StatelessWidget {
  final Quest quest;
  final Duration remaining;
  final bool isRunning;
  final bool isReady;
  final VoidCallback onConfirm;

  const _TimerProgressBody({
    required this.quest,
    required this.remaining,
    required this.isRunning,
    required this.isReady,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final totalSeconds = quest.estimatedMinutes * 60;
    final remainingSeconds = remaining.inSeconds.clamp(0, totalSeconds);
    final progress = totalSeconds == 0
        ? 1.0
        : 1 - (remainingSeconds / totalSeconds);

    return Column(
      children: [
        SizedBox(
          width: 116,
          height: 116,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 5,
                  backgroundColor: AppColors.divider,
                  color: isReady ? AppColors.gold : AppColors.textPrimary,
                ),
              ),
              if (isReady)
                const Icon(Icons.check_rounded, size: 40, color: AppColors.gold)
              else
                Text(
                  _formatDuration(remaining),
                  style: GoogleFonts.dmSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          isReady ? 'Время зафиксировано' : 'Фокус идёт',
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          isRunning
              ? 'Можно закрыть экран и вернуться позже.'
              : 'Теперь подтверди, что результат действительно готов.',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        if (isReady) ...[
          const SizedBox(height: 18),
          _VerificationPrimaryButton(
            label: 'Подтвердить результат',
            icon: Icons.verified_rounded,
            onPressed: onConfirm,
          ),
        ],
      ],
    );
  }
}

class _VerificationPrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _VerificationPrimaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          backgroundColor: AppColors.textPrimary,
          foregroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

String _formatDuration(Duration duration) {
  final totalSeconds = duration.inSeconds.clamp(0, 24 * 60 * 60);
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}';
}

Future<QuestFeedbackReason?> _showQuestFeedback(BuildContext context) {
  return showModalBottomSheet<QuestFeedbackReason>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    builder: (ctx) => SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Что не сработало?',
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 22,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Система учтёт это в следующих заданиях.',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            _QuestFeedbackOption(
              icon: Icons.trending_up_rounded,
              label: 'Слишком сложно',
              onTap: () => Navigator.pop(ctx, QuestFeedbackReason.tooHard),
            ),
            _QuestFeedbackOption(
              icon: Icons.alt_route_rounded,
              label: 'Не ведёт к моей цели',
              onTap: () => Navigator.pop(ctx, QuestFeedbackReason.notRelevant),
            ),
            _QuestFeedbackOption(
              icon: Icons.schedule_rounded,
              label: 'Сейчас нет времени',
              onTap: () => Navigator.pop(ctx, QuestFeedbackReason.noTime),
            ),
          ],
        ),
      ),
    ),
  );
}

void _showFeedbackSaved(BuildContext context) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Text(
          'Учту это в следующих заданиях.',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w600,
            color: AppColors.surface,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
      ),
    );
}

class _QuestFeedbackOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuestFeedbackOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 52,
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 18, color: AppColors.textSecondary),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestCriterionPreview extends StatelessWidget {
  final Quest quest;
  final bool compact;

  const _QuestCriterionPreview({required this.quest, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(Icons.flag_outlined, size: 14, color: AppColors.gold),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Готово, когда: ',
                    style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: quest.effectiveSuccessCriterion),
                ],
              ),
              maxLines: compact ? 2 : 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.dmSans(
                fontSize: compact ? 11.5 : 12.5,
                height: 1.35,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerificationBadge extends StatelessWidget {
  final Quest quest;

  const _VerificationBadge({required this.quest});

  @override
  Widget build(BuildContext context) {
    final isVerified =
        quest.verificationStatus == QuestVerificationStatus.verified ||
        quest.status == QuestStatus.completed;
    final isTimer = quest.verificationType == QuestVerificationType.timer;
    final isRunning =
        quest.verificationStatus == QuestVerificationStatus.inProgress;
    final String label;
    if (isVerified) {
      label = 'Проверено';
    } else if (isTimer && isRunning) {
      label = 'Таймер идёт';
    } else if (isTimer) {
      label = 'Таймер · ${quest.estimatedMinutes} мин';
    } else {
      label = 'Подтверждение';
    }
    final color = isVerified ? AppColors.gold : AppColors.textDisabled;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified ? Icons.verified_rounded : quest.verificationType.icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Main Quest Card (суперцель) — с Lottie burst при complete
// ---------------------------------------------------------------------------
class _MainQuestCard extends ConsumerStatefulWidget {
  final Quest quest;
  final VoidCallback onComplete;
  const _MainQuestCard({required this.quest, required this.onComplete});

  @override
  ConsumerState<_MainQuestCard> createState() => _MainQuestCardState();
}

class _MainQuestCardState extends ConsumerState<_MainQuestCard> {
  bool _showBurst = false;

  Future<void> _handleFeedback() async {
    final reason = await _showQuestFeedback(context);
    if (reason == null || !mounted) return;
    HapticFeedback.selectionClick();
    await ref
        .read(questNotifierProvider.notifier)
        .skipQuest(widget.quest.id, reason);
    if (mounted) _showFeedbackSaved(context);
  }

  Future<void> _handleComplete() async {
    final confirmed = await _showQuestVerification(context, widget.quest);
    if (!confirmed || !mounted) return;
    HapticFeedback.mediumImpact();
    ref.read(audioServiceProvider).playQuestComplete();
    setState(() => _showBurst = true);
    widget.onComplete();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _showBurst = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.quest.status == QuestStatus.completed;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        _buildCard(isCompleted),
        if (_showBurst)
          Positioned(
            right: 8,
            top: -16,
            child: RepaintBoundary(
              child: IgnorePointer(
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: Lottie.asset(
                    'assets/animations/lottie/quest_complete.json',
                    repeat: false,
                    delegates: LottieDelegates(
                      values: [
                        ValueDelegate.color(const [
                          '**',
                        ], value: AppColors.gold),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCard(bool isCompleted) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? AppColors.gold.withValues(alpha: 0.15)
              : AppColors.gold.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.stars_rounded,
                  size: 16,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'СУПЕРЦЕЛЬ',
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gold,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              if (!isCompleted)
                IconButton(
                  tooltip: 'Задание не подходит',
                  onPressed: _handleFeedback,
                  style: IconButton.styleFrom(
                    fixedSize: const Size(40, 40),
                    minimumSize: const Size(40, 40),
                    padding: EdgeInsets.zero,
                  ),
                  icon: const Icon(
                    Icons.more_horiz_rounded,
                    size: 19,
                    color: AppColors.textDisabled,
                  ),
                ),
              Row(
                children: List.generate(
                  widget.quest.difficulty.skulls,
                  (_) => const Padding(
                    padding: EdgeInsets.only(left: 2),
                    child: Icon(
                      Icons.whatshot,
                      size: 12,
                      color: AppColors.gold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.quest.title,
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 18,
              color: isCompleted
                  ? AppColors.textDisabled
                  : AppColors.textPrimary,
              letterSpacing: 0.5,
              decoration: isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.quest.description,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          if (widget.quest.tip.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              widget.quest.tip,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppColors.textDisabled,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 12),
          _QuestCriterionPreview(quest: widget.quest),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: _VerificationBadge(quest: widget.quest),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.schedule,
                size: 14,
                color: AppColors.textDisabled,
              ),
              const SizedBox(width: 4),
              Text(
                '${widget.quest.estimatedMinutes} мин',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: AppColors.textDisabled,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.bolt, size: 14, color: AppColors.gold),
              const SizedBox(width: 4),
              Text(
                '+${widget.quest.xpReward} XP',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gold,
                ),
              ),
              const Spacer(),
              if (!isCompleted)
                IconButton(
                  tooltip: 'Открыть проверку',
                  onPressed: _handleComplete,
                  style: IconButton.styleFrom(
                    fixedSize: const Size(40, 40),
                    minimumSize: const Size(40, 40),
                    padding: EdgeInsets.zero,
                    side: const BorderSide(color: AppColors.gold, width: 1.5),
                  ),
                  icon: Icon(
                    widget.quest.verificationType.icon,
                    size: 18,
                    color: AppColors.gold,
                  ),
                )
              else
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.gold,
                  ),
                  child: const Icon(Icons.check, size: 18, color: Colors.white),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Daily Quest Card — с Lottie burst при complete
// ---------------------------------------------------------------------------
class _QuestCard extends ConsumerStatefulWidget {
  final Quest quest;
  final VoidCallback onComplete;
  const _QuestCard({required this.quest, required this.onComplete});

  @override
  ConsumerState<_QuestCard> createState() => _QuestCardState();
}

class _QuestCardState extends ConsumerState<_QuestCard> {
  bool _showBurst = false;

  Future<void> _handleFeedback() async {
    final reason = await _showQuestFeedback(context);
    if (reason == null || !mounted) return;
    HapticFeedback.selectionClick();
    await ref
        .read(questNotifierProvider.notifier)
        .skipQuest(widget.quest.id, reason);
    if (mounted) _showFeedbackSaved(context);
  }

  Future<void> _handleComplete() async {
    final confirmed = await _showQuestVerification(context, widget.quest);
    if (!confirmed || !mounted) return;
    HapticFeedback.mediumImpact();
    ref.read(audioServiceProvider).playQuestComplete();
    setState(() => _showBurst = true);
    widget.onComplete();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _showBurst = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.quest.status == QuestStatus.completed;
    final sphereColor = widget.quest.category.color;
    final sphereIcon = widget.quest.category.icon;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Карточка
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.divider.withValues(
                  alpha: isCompleted ? 0.45 : 1,
                ),
              ),
            ),
          ),
          child: Row(
            children: [
              // Sphere icon badge
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.divider.withValues(alpha: 0.4)
                      : sphereColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  sphereIcon,
                  size: 18,
                  color: isCompleted ? AppColors.textDisabled : sphereColor,
                ),
              ),
              const SizedBox(width: 14),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.quest.title,
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isCompleted
                                  ? AppColors.textDisabled
                                  : AppColors.textPrimary,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        if (!isCompleted)
                          IconButton(
                            tooltip: 'Задание не подходит',
                            onPressed: _handleFeedback,
                            style: IconButton.styleFrom(
                              fixedSize: const Size(40, 40),
                              minimumSize: const Size(40, 40),
                              padding: EdgeInsets.zero,
                            ),
                            icon: const Icon(
                              Icons.more_horiz_rounded,
                              size: 19,
                              color: AppColors.textDisabled,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.quest.description,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 7),
                    _QuestCriterionPreview(quest: widget.quest, compact: true),
                    const SizedBox(height: 7),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _VerificationBadge(quest: widget.quest),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 12,
                          color: AppColors.textDisabled,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${widget.quest.estimatedMinutes} мин',
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: AppColors.textDisabled,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          widget.quest.category.label,
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: isCompleted
                                ? AppColors.textDisabled
                                : sphereColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // XP + кнопка
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '+${widget.quest.xpReward} XP',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isCompleted
                          ? AppColors.textDisabled
                          : AppColors.gold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  IconButton(
                    tooltip: isCompleted ? 'Выполнено' : 'Завершить задание',
                    onPressed: isCompleted ? null : _handleComplete,
                    style: IconButton.styleFrom(
                      fixedSize: const Size(34, 34),
                      minimumSize: const Size(34, 34),
                      padding: EdgeInsets.zero,
                      backgroundColor: isCompleted
                          ? sphereColor
                          : Colors.transparent,
                      side: BorderSide(
                        color: isCompleted ? sphereColor : AppColors.divider,
                        width: 1.5,
                      ),
                    ),
                    icon: Icon(
                      Icons.check_rounded,
                      size: 17,
                      color: isCompleted
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Gold burst при выполнении
        if (_showBurst)
          Positioned(
            right: 0,
            top: -20,
            child: RepaintBoundary(
              child: IgnorePointer(
                child: SizedBox(
                  width: 70,
                  height: 70,
                  child: Lottie.asset(
                    'assets/animations/lottie/quest_complete.json',
                    repeat: false,
                    delegates: LottieDelegates(
                      values: [
                        ValueDelegate.color(const [
                          '**',
                        ], value: AppColors.gold),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Error Card
// ---------------------------------------------------------------------------
class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            message,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Повторить',
              style: GoogleFonts.dmSans(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
