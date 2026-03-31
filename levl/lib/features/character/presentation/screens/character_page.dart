import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/achievement_model.dart';
import '../../../dashboard/presentation/providers/quest_provider.dart';
import '../widgets/stats_radar_chart.dart';

class CharacterPage extends ConsumerWidget {
  const CharacterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: userAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Ошибка: $e')),
          data: (user) => CustomScrollView(
            slivers: [
              // --- Header ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      Text(
                        'Персонаж',
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 24,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Уровень ${user.level}',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- Avatar + Name ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Column(
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surface,
                          border: Border.all(color: AppColors.gold, width: 2.5),
                        ),
                        child: Center(
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                            style: GoogleFonts.dmSerifDisplay(
                              fontSize: 36,
                              color: AppColors.gold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user.name,
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 22,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _titleForLevel(user.level),
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- Radar Chart ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
                  child: Column(
                    children: [
                      Text(
                        'ХАРАКТЕРИСТИКИ',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: StatsRadarChart(
                          stats: [
                            StatAxis(
                              label: 'Дисциплина',
                              icon: Icons.bolt,
                              color: AppColors.sphereDiscipline,
                              value: user.stats.discipline,
                            ),
                            StatAxis(
                              label: 'Знания',
                              icon: Icons.menu_book,
                              color: AppColors.sphereKnowledge,
                              value: user.stats.knowledge,
                            ),
                            StatAxis(
                              label: 'Отношения',
                              icon: Icons.people,
                              color: AppColors.sphereRelations,
                              value: user.stats.relations,
                            ),
                            StatAxis(
                              label: 'Энергия',
                              icon: Icons.local_fire_department,
                              color: AppColors.sphereEnergy,
                              value: user.stats.energy,
                            ),
                            StatAxis(
                              label: 'Воля',
                              icon: Icons.my_location,
                              color: AppColors.sphereWill,
                              value: user.stats.will,
                            ),
                            StatAxis(
                              label: 'Мудрость',
                              icon: Icons.psychology,
                              color: AppColors.sphereWisdom,
                              value: user.stats.wisdom,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- Stats list (detailed) ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                  child: Column(
                    children: [
                      _StatBar(label: 'Дисциплина', value: user.stats.discipline, color: AppColors.sphereDiscipline, icon: Icons.bolt),
                      _StatBar(label: 'Знания', value: user.stats.knowledge, color: AppColors.sphereKnowledge, icon: Icons.menu_book),
                      _StatBar(label: 'Отношения', value: user.stats.relations, color: AppColors.sphereRelations, icon: Icons.people),
                      _StatBar(label: 'Энергия', value: user.stats.energy, color: AppColors.sphereEnergy, icon: Icons.local_fire_department),
                      _StatBar(label: 'Воля', value: user.stats.will, color: AppColors.sphereWill, icon: Icons.my_location),
                      _StatBar(label: 'Мудрость', value: user.stats.wisdom, color: AppColors.sphereWisdom, icon: Icons.psychology),
                    ],
                  ),
                ),
              ),

              // --- Achievements ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
                  child: Text(
                    'ДОСТИЖЕНИЯ',
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
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final achievement = allAchievements[index];
                      final unlocked = achievement.isUnlocked(
                        level: user.level,
                        streak: user.currentStreak,
                        questsCompleted: user.questsCompleted,
                        sphereStats: {
                          'discipline': user.stats.discipline,
                          'knowledge': user.stats.knowledge,
                          'relations': user.stats.relations,
                          'energy': user.stats.energy,
                          'will': user.stats.will,
                          'wisdom': user.stats.wisdom,
                        },
                      );
                      return _AchievementCard(
                        achievement: achievement,
                        unlocked: unlocked,
                      );
                    },
                    childCount: allAchievements.length,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  static String _titleForLevel(int level) => switch (level) {
    1 => 'Новичок',
    2 => 'Ученик',
    3 => 'Практик',
    4 => 'Адепт',
    5 => 'Мастер пути',
    >= 6 && < 10 => 'Воин Системы',
    >= 10 && < 20 => 'Хранитель',
    >= 20 => 'Легенда',
    _ => 'Путник',
  };
}

// --- Stat Bar ---
class _StatBar extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;

  const _StatBar({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 10),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: value / 100,
                backgroundColor: AppColors.divider,
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 28,
            child: Text(
              '$value',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Achievement Card ---
class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final bool unlocked;

  const _AchievementCard({
    required this.achievement,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: unlocked ? AppColors.gold.withValues(alpha: 0.4) : AppColors.divider,
        ),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            achievement.icon,
            size: 24,
            color: unlocked ? AppColors.gold : AppColors.textDisabled,
          ),
          const SizedBox(height: 6),
          Text(
            achievement.title,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: unlocked ? AppColors.textPrimary : AppColors.textDisabled,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            achievement.description,
            style: GoogleFonts.dmSans(
              fontSize: 9,
              color: unlocked ? AppColors.textSecondary : AppColors.textDisabled,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
