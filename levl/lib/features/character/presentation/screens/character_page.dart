import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/achievement_model.dart';
import '../../../../shared/models/avatar_config.dart';
import '../../../../shared/models/quest_model.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/widgets/premium_face_avatar_widget.dart';
import '../../../dashboard/presentation/providers/quest_provider.dart';
import '../widgets/stats_radar_chart.dart';
import 'avatar_editor_screen.dart';

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
                      GestureDetector(
                        onTap: () => _openAvatarEditor(context),
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            PremiumFaceAvatarWidget(
                              config: _avatarFromUser(user),
                              size: 190,
                              level: user.level,
                              streak: user.currentStreak,
                            ),
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: AppColors.textPrimary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.background, width: 2.5),
                              ),
                              child: const Icon(Icons.edit,
                                  size: 14, color: Colors.white),
                            ),
                          ],
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
                                rankName:
                                    sphereRankName(user.stats.discipline)),
                            StatAxis(
                                label: 'Знания',
                                icon: Icons.menu_book,
                                color: AppColors.sphereKnowledge,
                                value: user.stats.knowledge,
                                rankName: sphereRankName(user.stats.knowledge)),
                            StatAxis(
                                label: 'Отношения',
                                icon: Icons.people,
                                color: AppColors.sphereRelations,
                                value: user.stats.relations,
                                rankName: sphereRankName(user.stats.relations)),
                            StatAxis(
                                label: 'Энергия',
                                icon: Icons.local_fire_department,
                                color: AppColors.sphereEnergy,
                                value: user.stats.energy,
                                rankName: sphereRankName(user.stats.energy)),
                            StatAxis(
                                label: 'Воля',
                                icon: Icons.my_location,
                                color: AppColors.sphereWill,
                                value: user.stats.will,
                                rankName: sphereRankName(user.stats.will)),
                            StatAxis(
                                label: 'Мудрость',
                                icon: Icons.psychology,
                                color: AppColors.sphereWisdom,
                                value: user.stats.wisdom,
                                rankName: sphereRankName(user.stats.wisdom)),
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
                      _StatBar(
                          label: 'Дисциплина',
                          description: QuestCategory.discipline.description,
                          value: user.stats.discipline,
                          color: AppColors.sphereDiscipline,
                          icon: Icons.bolt),
                      _StatBar(
                          label: 'Знания',
                          description: QuestCategory.knowledge.description,
                          value: user.stats.knowledge,
                          color: AppColors.sphereKnowledge,
                          icon: Icons.menu_book),
                      _StatBar(
                          label: 'Отношения',
                          description: QuestCategory.relations.description,
                          value: user.stats.relations,
                          color: AppColors.sphereRelations,
                          icon: Icons.people),
                      _StatBar(
                          label: 'Энергия',
                          description: QuestCategory.energy.description,
                          value: user.stats.energy,
                          color: AppColors.sphereEnergy,
                          icon: Icons.local_fire_department),
                      _StatBar(
                          label: 'Воля',
                          description: QuestCategory.will.description,
                          value: user.stats.will,
                          color: AppColors.sphereWill,
                          icon: Icons.my_location),
                      _StatBar(
                          label: 'Мудрость',
                          description: QuestCategory.wisdom.description,
                          value: user.stats.wisdom,
                          color: AppColors.sphereWisdom,
                          icon: Icons.psychology),
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

  void _openAvatarEditor(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AvatarEditorScreen()),
    );
  }

  static AvatarConfig _avatarFromUser(UserProfile user) {
    if (user.characterStateJson.isEmpty) return const AvatarConfig();
    return AvatarConfig.fromJsonString(user.characterStateJson);
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

class _StatBar extends StatelessWidget {
  final String label;
  final String description;
  final int value;
  final Color color;
  final IconData icon;

  const _StatBar({
    required this.label,
    required this.description,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final rank = sphereRankName(value);
    final progress = sphereRankProgress(value);
    final toNext = sphereXpToNextRank(value);
    final isMaxRank = toNext == 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Иконка-бейдж с цветом сферы
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 12),
              // Название + описание
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          label,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isMaxRank
                                ? AppColors.gold.withValues(alpha: 0.1)
                                : color.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            rank,
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isMaxRank ? AppColors.gold : color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: progress),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) => Stack(
                    children: [
                      Container(
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.divider,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: v.clamp(0.0, 1.0),
                        child: Container(
                          height: 5,
                          decoration: BoxDecoration(
                            color: isMaxRank ? AppColors.gold : color,
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: v > 0.02
                                ? [
                                    BoxShadow(
                                        color: color.withValues(alpha: 0.35),
                                        blurRadius: 6)
                                  ]
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                isMaxRank ? '✦ Максимум' : '$toNext XP',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: isMaxRank ? AppColors.gold : AppColors.textDisabled,
                  fontWeight: isMaxRank ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
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
          color: unlocked
              ? AppColors.gold.withValues(alpha: 0.4)
              : AppColors.divider,
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
              color:
                  unlocked ? AppColors.textSecondary : AppColors.textDisabled,
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
