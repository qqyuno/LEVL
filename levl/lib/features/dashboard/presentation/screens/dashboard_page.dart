import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/models/quest_model.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Replace with real providers in Phase 4
    const mockUser = UserProfile(
      id: 'mock',
      name: 'Артём',
      level: 3,
      xp: 240,
      currentStreak: 7,
    );

    final mockQuests = [
      Quest(
        id: '1', userId: 'mock',
        title: 'Утренняя цитадель',
        description: 'Медитация 10 минут перед началом дня',
        tip: 'Первые 10 минут определяют тон всего дня.',
        xpReward: 25,
        category: QuestCategory.discipline,
        difficulty: QuestDifficulty.easy,
        createdAt: _mockDate,
      ),
      Quest(
        id: '2', userId: 'mock',
        title: 'Кодекс Знаний',
        description: 'Прочитать 20 страниц книги по профессии',
        tip: 'Знание — единственный ресурс, который множится при использовании.',
        xpReward: 50,
        category: QuestCategory.knowledge,
        difficulty: QuestDifficulty.medium,
        createdAt: _mockDate,
      ),
      Quest(
        id: '3', userId: 'mock',
        title: 'Контракт с телом',
        description: 'Тренировка 30 минут',
        tip: 'Тело — первый инструмент воли.',
        xpReward: 50,
        category: QuestCategory.energy,
        difficulty: QuestDifficulty.medium,
        createdAt: _mockDate,
      ),
    ];

    final mainQuest = Quest(
      id: 'main', userId: 'mock',
      title: 'Запуск первой версии LEVL',
      description: 'Создать рабочий прототип приложения и показать первым 10 пользователям.',
      tip: 'Путь в тысячу ли начинается с первого шага.',
      xpReward: 500,
      category: QuestCategory.discipline,
      difficulty: QuestDifficulty.epic,
      type: QuestType.main,
      estimatedMinutes: 2160,
      createdAt: _mockDate,
    );

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // --- Header ---
            SliverToBoxAdapter(
              child: _DashboardHeader(user: mockUser),
            ),

            // --- Hero: Avatar + XP ---
            SliverToBoxAdapter(
              child: _HeroSegment(user: mockUser),
            ),

            // --- Main Quest ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: _MainQuestCard(quest: mainQuest),
              ),
            ),

            // --- Daily Quests ---
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

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _QuestCard(quest: mockQuests[index]),
                  ),
                  childCount: mockQuests.length,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),

      // --- FAB: AI Mentor ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {}, // TODO: Phase 7
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

// Mock date for placeholder data — DateTime has no const constructor
final _mockDate = DateTime.utc(2026, 3, 28);

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
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Из Хаоса в Контроль',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.5,
                ),
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
                user.name[0].toUpperCase(),
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

// --- Main Quest Card ---
class _MainQuestCard extends StatelessWidget {
  final Quest quest;
  const _MainQuestCard({required this.quest});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'ГЛАВНАЯ ЦЕЛЬ',
                style: GoogleFonts.dmSerifDisplay(
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
                    child: Icon(Icons.whatshot,
                        size: 12, color: AppColors.gold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            quest.title,
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            quest.description,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.bolt, size: 14, color: AppColors.gold),
              const SizedBox(width: 4),
              Text(
                '${quest.xpReward} XP',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gold,
                ),
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
  const _QuestCard({required this.quest});

  Color get _categoryColor => switch (quest.category) {
    QuestCategory.discipline => AppColors.skillDiscipline,
    QuestCategory.knowledge  => AppColors.skillKnowledge,
    QuestCategory.relations  => AppColors.skillRelations,
    QuestCategory.energy     => AppColors.skillEnergy,
    QuestCategory.will       => AppColors.skillWill,
    QuestCategory.wisdom     => AppColors.skillWisdom,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Row(
        children: [
          // Category color indicator
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: _categoryColor,
              borderRadius: BorderRadius.circular(2),
            ),
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
                    color: AppColors.textPrimary,
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
              ],
            ),
          ),

          const SizedBox(width: 12),

          // XP badge + complete button
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${quest.xpReward}',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () {}, // TODO: Phase 4 — complete quest
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.divider, width: 1.5),
                  ),
                  child: quest.status == QuestStatus.completed
                      ? const Icon(Icons.check,
                          size: 16, color: AppColors.gold)
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
