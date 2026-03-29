import 'package:flutter/material.dart';

/// Achievement unlock condition type.
enum UnlockCondition {
  level,        // reach a certain level
  streak,       // maintain streak for N days
  questsTotal,  // complete N quests total
  sphereLevel,  // reach N points in a specific sphere
}

/// A single achievement that unlocks equipment.
class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final UnlockCondition condition;
  final int requiredValue;
  final String? requiredSphere; // for sphereLevel condition

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.condition,
    required this.requiredValue,
    this.requiredSphere,
  });

  /// Check if this achievement is unlocked with given profile data.
  bool isUnlocked({
    required int level,
    required int streak,
    required int questsCompleted,
    required Map<String, int> sphereStats,
  }) {
    return switch (condition) {
      UnlockCondition.level => level >= requiredValue,
      UnlockCondition.streak => streak >= requiredValue,
      UnlockCondition.questsTotal => questsCompleted >= requiredValue,
      UnlockCondition.sphereLevel =>
        (sphereStats[requiredSphere] ?? 0) >= requiredValue,
    };
  }
}

/// All achievements in the game.
/// Unlocked achievements show in gold, locked in grey.
const allAchievements = [
  // --- Level milestones ---
  Achievement(
    id: 'first_step',
    title: 'Первый шаг',
    description: 'Достигни 2 уровня',
    icon: Icons.looks_one,
    condition: UnlockCondition.level,
    requiredValue: 2,
  ),
  Achievement(
    id: 'rising',
    title: 'На подъёме',
    description: 'Достигни 5 уровня',
    icon: Icons.trending_up,
    condition: UnlockCondition.level,
    requiredValue: 5,
  ),
  Achievement(
    id: 'decade',
    title: 'Десятка',
    description: 'Достигни 10 уровня',
    icon: Icons.workspace_premium,
    condition: UnlockCondition.level,
    requiredValue: 10,
  ),

  // --- Streak milestones ---
  Achievement(
    id: 'week_warrior',
    title: 'Воин недели',
    description: '7 дней подряд',
    icon: Icons.local_fire_department,
    condition: UnlockCondition.streak,
    requiredValue: 7,
  ),
  Achievement(
    id: 'month_master',
    title: 'Хозяин месяца',
    description: '30 дней подряд',
    icon: Icons.shield,
    condition: UnlockCondition.streak,
    requiredValue: 30,
  ),
  Achievement(
    id: 'unstoppable',
    title: 'Неудержимый',
    description: '100 дней подряд',
    icon: Icons.diamond,
    condition: UnlockCondition.streak,
    requiredValue: 100,
  ),

  // --- Quest milestones ---
  Achievement(
    id: 'first_quest',
    title: 'Начало',
    description: 'Выполни первое задание',
    icon: Icons.check_circle_outline,
    condition: UnlockCondition.questsTotal,
    requiredValue: 1,
  ),
  Achievement(
    id: 'fifty_quests',
    title: 'Полсотни',
    description: '50 заданий выполнено',
    icon: Icons.emoji_events,
    condition: UnlockCondition.questsTotal,
    requiredValue: 50,
  ),

  // --- Sphere mastery ---
  Achievement(
    id: 'discipline_adept',
    title: 'Адепт Дисциплины',
    description: 'Дисциплина 50+',
    icon: Icons.bolt,
    condition: UnlockCondition.sphereLevel,
    requiredValue: 50,
    requiredSphere: 'discipline',
  ),
  Achievement(
    id: 'knowledge_adept',
    title: 'Адепт Знаний',
    description: 'Знания 50+',
    icon: Icons.menu_book,
    condition: UnlockCondition.sphereLevel,
    requiredValue: 50,
    requiredSphere: 'knowledge',
  ),
  Achievement(
    id: 'energy_adept',
    title: 'Адепт Энергии',
    description: 'Энергия 50+',
    icon: Icons.local_fire_department,
    condition: UnlockCondition.sphereLevel,
    requiredValue: 50,
    requiredSphere: 'energy',
  ),
  Achievement(
    id: 'will_adept',
    title: 'Адепт Воли',
    description: 'Воля 50+',
    icon: Icons.my_location,
    condition: UnlockCondition.sphereLevel,
    requiredValue: 50,
    requiredSphere: 'will',
  ),
];
