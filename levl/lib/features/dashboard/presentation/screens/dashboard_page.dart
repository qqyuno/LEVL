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
                    onComplete: (quest) => ref
                        .read(questNotifierProvider.notifier)
                        .completeQuest(quest.id),
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
                    final mainQuest =
                        quests.where((q) => q.isMainGoalTask).firstOrNull;
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
                      .where((q) =>
                          !q.isMainGoalTask && q.status == QuestStatus.pending)
                      .firstOrNull;
                  final daily = quests
                      .where((q) => !q.isMainGoalTask && q.id != nextQuest?.id)
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

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scale = Tween(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    if (widget.user.currentStreak > 0) {
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
    final dailyQuests = quests.where((quest) => !quest.isMainGoalTask).toList();
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
                  : () async {
                      final confirmed = await _showSystemConfirmation(
                        context,
                        nextQuest.title,
                      );
                      if (confirmed) onComplete(nextQuest);
                    },
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
                    Icon(
                      nextQuest == null
                          ? Icons.auto_awesome
                          : Icons.check_rounded,
                      size: 17,
                      color: AppColors.surface,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      nextQuest == null
                          ? 'Открыть Систему'
                          : 'Зафиксировать выполнение',
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

Future<bool> _showSystemConfirmation(
    BuildContext context, String questTitle) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    isScrollControlled: true,
    builder: (ctx) => Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 28),
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            'СИСТЕМА',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.gold,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Зафиксировано.\nСистема доверяет тебе.',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 24,
              color: AppColors.textPrimary,
              height: 1.3,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            questTitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: () => Navigator.of(ctx).pop(true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'Подтвердить',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.background,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Ещё не выполнено',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    ),
  );
  return result ?? false;
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

  Future<void> _handleComplete() async {
    final confirmed =
        await _showSystemConfirmation(context, widget.quest.title);
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
                        ValueDelegate.color(
                          const ['**'],
                          value: AppColors.gold,
                        ),
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
              Row(
                children: List.generate(
                  widget.quest.difficulty.skulls,
                  (_) => const Padding(
                    padding: EdgeInsets.only(left: 2),
                    child:
                        Icon(Icons.whatshot, size: 12, color: AppColors.gold),
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
              color:
                  isCompleted ? AppColors.textDisabled : AppColors.textPrimary,
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
          Row(
            children: [
              const Icon(Icons.schedule,
                  size: 14, color: AppColors.textDisabled),
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
                GestureDetector(
                  onTap: _handleComplete,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.gold, width: 1.5),
                    ),
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

  Future<void> _handleComplete() async {
    final confirmed =
        await _showSystemConfirmation(context, widget.quest.title);
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isCompleted ? AppColors.surfaceElevated : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCompleted
                  ? AppColors.divider.withValues(alpha: 0.5)
                  : AppColors.divider,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Sphere icon badge
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.divider.withValues(alpha: 0.4)
                      : sphereColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  sphereIcon,
                  size: 20,
                  color: isCompleted ? AppColors.textDisabled : sphereColor,
                ),
              ),
              const SizedBox(width: 14),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.quest.title,
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isCompleted
                            ? AppColors.textDisabled
                            : AppColors.textPrimary,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.quest.description,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
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
                    '+${widget.quest.xpReward}',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color:
                          isCompleted ? AppColors.textDisabled : AppColors.gold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: isCompleted ? null : _handleComplete,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted ? sphereColor : Colors.transparent,
                        border: Border.all(
                          color: isCompleted ? sphereColor : AppColors.divider,
                          width: 1.5,
                        ),
                      ),
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
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
                        ValueDelegate.color(
                          const ['**'],
                          value: AppColors.gold,
                        ),
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
