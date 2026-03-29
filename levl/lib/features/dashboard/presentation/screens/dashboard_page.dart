import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/models/quest_model.dart';
import '../providers/quest_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileNotifierProvider);
    final questsAsync = ref.watch(questNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: userAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Ошибка: $e')),
          data: (user) => CustomScrollView(
            slivers: [
              // --- Header ---
              SliverToBoxAdapter(
                child: _DashboardHeader(user: user),
              ),

              // --- Hero: Avatar + XP ---
              SliverToBoxAdapter(
                child: _HeroSegment(user: user),
              ),

              // --- Main Quest (first isMainGoalTask quest) ---
              SliverToBoxAdapter(
                child: questsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator(color: AppColors.gold)),
                  ),
                  error: (e, _) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: _ErrorCard(
                      message: 'Не удалось загрузить задания',
                      onRetry: () => ref.read(questNotifierProvider.notifier).fetchFromEdgeFunction(),
                    ),
                  ),
                  data: (quests) {
                    final mainQuest = quests.where((q) => q.isMainGoalTask).firstOrNull;
                    if (mainQuest == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: _MainQuestCard(
                        quest: mainQuest,
                        onComplete: () => ref.read(questNotifierProvider.notifier).completeQuest(mainQuest.id),
                      ),
                    );
                  },
                ),
              ),

              // --- Daily Quests label ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
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

              // --- Daily Quest Cards ---
              questsAsync.when(
                loading: () => const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
                data: (quests) {
                  final daily = quests.where((q) => !q.isMainGoalTask).toList();
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _QuestCard(
                            quest: daily[index],
                            onComplete: () => ref.read(questNotifierProvider.notifier).completeQuest(daily[index].id),
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

      // --- FAB: AI Mentor ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {}, // TODO: Phase 6
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.gold,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.gold, width: 1),
        ),
        label: Text(
          'Система',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.gold,
            letterSpacing: 0.5,
          ),
        ),
        icon: const Icon(Icons.auto_awesome, size: 18),
      ),
    );
  }
}

// --- Error Card ---
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
          Text(message, style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onRetry,
            child: Text('Повторить', style: GoogleFonts.dmSans(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// --- Header Widget ---
class _DashboardHeader extends StatelessWidget {
  final UserProfile user;
  const _DashboardHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'УРОВЕНЬ ${user.level}',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                user.mainGoal.isNotEmpty ? user.mainGoal : 'Путь начинается',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          // Streak
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department,
                    color: AppColors.warning, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${user.currentStreak}',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
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

// --- Hero Segment ---
class _HeroSegment extends StatelessWidget {
  final UserProfile user;
  const _HeroSegment({required this.user});

  @override
  Widget build(BuildContext context) {
    final progress = levelProgress(user.xp, user.level);
    final xpToNext = xpForLevel(user.level);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        children: [
          // Avatar placeholder
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              border: Border.all(color: AppColors.gold, width: 2),
            ),
            child: Center(
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            user.name,
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),

          // XP Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${user.xp} XP',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gold,
                    ),
                  ),
                  Text(
                    '$xpToNext XP до уровня ${user.level + 1}',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.surface,
                  valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Main Quest Card (суперцель) ---
class _MainQuestCard extends StatelessWidget {
  final Quest quest;
  final VoidCallback onComplete;
  const _MainQuestCard({required this.quest, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    final isCompleted = quest.status == QuestStatus.completed;

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
              // Gold star icon for supergoal
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.stars_rounded, size: 16, color: AppColors.gold),
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
              // Skulls
              Row(
                children: List.generate(
                  quest.difficulty.skulls,
                  (_) => const Padding(
                    padding: EdgeInsets.only(left: 2),
                    child: Icon(Icons.whatshot, size: 12, color: AppColors.gold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            quest.title,
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isCompleted ? AppColors.textDisabled : AppColors.textPrimary,
              letterSpacing: 0.5,
              decoration: isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            quest.description,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          if (quest.tip.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              quest.tip,
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
              // Time
              const Icon(Icons.schedule, size: 14, color: AppColors.textDisabled),
              const SizedBox(width: 4),
              Text(
                '${quest.estimatedMinutes} мин',
                style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textDisabled),
              ),
              const SizedBox(width: 16),
              // XP
              const Icon(Icons.bolt, size: 14, color: AppColors.gold),
              const SizedBox(width: 4),
              Text(
                '+${quest.xpReward} XP',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gold,
                ),
              ),
              const Spacer(),
              // Complete button
              if (!isCompleted)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    onComplete();
                  },
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

// --- Daily Quest Card ---
class _QuestCard extends StatelessWidget {
  final Quest quest;
  final VoidCallback onComplete;
  const _QuestCard({required this.quest, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    final isCompleted = quest.status == QuestStatus.completed;
    final sphereColor = quest.category.color;
    final sphereIcon = quest.category.icon;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted ? AppColors.surface.withValues(alpha: 0.7) : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Row(
        children: [
          // Sphere icon badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: sphereColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(sphereIcon, size: 20, color: sphereColor),
          ),
          const SizedBox(width: 14),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quest.title,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? AppColors.textDisabled : AppColors.textPrimary,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  quest.description,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    // Time
                    const Icon(Icons.schedule, size: 12, color: AppColors.textDisabled),
                    const SizedBox(width: 3),
                    Text(
                      '${quest.estimatedMinutes} мин',
                      style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textDisabled),
                    ),
                    const SizedBox(width: 12),
                    // Sphere label
                    Text(
                      quest.category.label,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: sphereColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // XP + complete button
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${quest.xpReward}',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isCompleted ? AppColors.textDisabled : AppColors.gold,
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: isCompleted
                    ? null
                    : () {
                        HapticFeedback.mediumImpact();
                        onComplete();
                      },
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
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
