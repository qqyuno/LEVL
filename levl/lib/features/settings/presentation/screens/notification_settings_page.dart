import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/supabase/isar_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/notifications/notification_provider.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../shared/models/quest_model.dart';
import '../../../../shared/models/user_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../dashboard/presentation/providers/quest_provider.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';

class NotificationSettingsPage extends ConsumerWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(notificationSettingsNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Настройки'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
        data: (settings) => _SettingsBody(settings: settings),
      ),
    );
  }
}

class _SettingsBody extends ConsumerWidget {
  final NotificationSettings settings;
  const _SettingsBody({required this.settings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(notificationSettingsNotifierProvider.notifier);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        // System voice hint
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: const Text(
            'Система напоминает коротко и по делу.\nБез спама. Максимум 2 раза в день.',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Master toggle
        _SettingsTile(
          title: 'Уведомления',
          subtitle: 'Полная тишина, если выключить',
          trailing: Switch.adaptive(
            value: settings.enabled,
            activeTrackColor: AppColors.textPrimary,
            onChanged: (v) async {
              await notifier.setEnabled(v);
              await _reschedule(ref);
            },
          ),
        ),

        const SizedBox(height: 32),
        const Divider(color: AppColors.divider),
        const SizedBox(height: 16),

        _SettingsTile(
          title: 'Политика конфиденциальности',
          subtitle: 'Какие данные собирает LEVL и зачем',
          trailing: const Icon(
            Icons.privacy_tip_outlined,
            color: AppColors.textSecondary,
            size: 20,
          ),
          onTap: () => context.push(AppRoutes.privacyPolicy),
        ),

        const SizedBox(height: 12),

        _SettingsTile(
          title: 'Условия и ограничения',
          subtitle: 'AI-подсказки не заменяют специалиста',
          trailing: const Icon(
            Icons.description_outlined,
            color: AppColors.textSecondary,
            size: 20,
          ),
          onTap: () => context.push(AppRoutes.terms),
        ),

        const SizedBox(height: 12),

        _SettingsTile(
          title: 'Удалить аккаунт и данные',
          subtitle: 'Профиль, задачи, кеш и прогресс будут удалены',
          trailing: const Icon(
            Icons.delete_outline,
            color: AppColors.error,
            size: 20,
          ),
          onTap: () => _confirmDeleteAccount(context, ref),
        ),

        const SizedBox(height: 12),

        // Sign out
        _SettingsTile(
          title: 'Выйти из аккаунта',
          subtitle: 'Вернуться к экрану входа',
          trailing: const Icon(Icons.logout,
              color: AppColors.textSecondary, size: 20),
          onTap: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: AppColors.surface,
                title: const Text('Выйти?',
                    style: TextStyle(color: AppColors.textPrimary)),
                content: const Text(
                  'Данные сохранены локально и восстановятся при входе.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Отмена',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Выйти',
                        style: TextStyle(color: AppColors.textPrimary)),
                  ),
                ],
              ),
            );
            if (confirm == true) {
              await ref.read(authNotifierProvider.notifier).signOut();
            }
          },
        ),

        if (settings.enabled) ...[
          const SizedBox(height: 16),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 16),

          // Morning time
          _SettingsTile(
            title: 'Утреннее напоминание',
            subtitle: _formatTime(settings.morningTime),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: settings.morningTime,
                builder: (context, child) => Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: AppColors.textPrimary,
                      onSurface: AppColors.textPrimary,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) {
                await notifier.setMorningTime(picked);
                await _reschedule(ref);
              }
            },
            trailing: const Icon(
              Icons.schedule,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),

          const SizedBox(height: 12),

          // Streak alert
          _SettingsTile(
            title: 'Стрик в опасности',
            subtitle: 'Вечером, если задачи не выполнены',
            trailing: Switch.adaptive(
              value: settings.streakAlert,
              activeTrackColor: AppColors.textPrimary,
              onChanged: (v) async {
                await notifier.setStreakAlert(v);
                await _reschedule(ref);
              },
            ),
          ),

          const SizedBox(height: 12),

          // Return alert
          _SettingsTile(
            title: 'Возвращение',
            subtitle: 'Если не заходил 2 дня',
            trailing: Switch.adaptive(
              value: settings.returnAlert,
              activeTrackColor: AppColors.textPrimary,
              onChanged: (v) async {
                await notifier.setReturnAlert(v);
                await _reschedule(ref);
              },
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _reschedule(WidgetRef ref) async {
    final profile = ref.read(userProfileNotifierProvider).valueOrNull;
    await NotificationService.instance.scheduleAll(
      dailyMinutes: profile?.dailyMinutes ?? 30,
      currentStreak: profile?.currentStreak ?? 0,
    );
  }

  Future<void> _confirmDeleteAccount(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Удалить аккаунт?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'LEVL удалит профиль, задачи, кеш задач, ежедневные отметки и аккаунт авторизации. Это действие нельзя отменить.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Отмена',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Удалить',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.gold),
      ),
    );

    try {
      await ref.read(authNotifierProvider.notifier).deleteAccount();
      final authState = ref.read(authNotifierProvider);
      if (authState.hasError) {
        throw authState.error!;
      }

      await _clearLocalAccountData(ref);
      ref.invalidate(onboardingCompleteProvider);
      ref.invalidate(userProfileNotifierProvider);
      ref.invalidate(questNotifierProvider);

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        context.go(AppRoutes.welcome);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Не удалось удалить аккаунт: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _clearLocalAccountData(WidgetRef ref) async {
    final isar = await ref.read(isarProvider.future);
    await isar.writeTxn(() async {
      await isar.questLocals.clear();
      await isar.userProfileLocals.clear();
    });
  }

  String _formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
