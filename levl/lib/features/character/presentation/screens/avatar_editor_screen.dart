import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar/isar.dart';

import '../../../../core/supabase/isar_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/avatar_config.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/widgets/avatar_widget.dart';
import '../../../dashboard/presentation/providers/quest_provider.dart';

class AvatarEditorScreen extends ConsumerStatefulWidget {
  const AvatarEditorScreen({super.key});

  @override
  ConsumerState<AvatarEditorScreen> createState() => _AvatarEditorScreenState();
}

class _AvatarEditorScreenState extends ConsumerState<AvatarEditorScreen> {
  late AvatarConfig _config;
  int _currentSection = 0;

  static const _sections = [
    ('Пресеты', Icons.auto_awesome_rounded),
    ('Фон', Icons.wallpaper_rounded),
    ('Рамка', Icons.radio_button_unchecked_rounded),
    ('Аура', Icons.blur_on_rounded),
    ('Знак', Icons.workspace_premium_rounded),
    ('Волосы', Icons.face_rounded),
    ('Брови', Icons.visibility_rounded),
    ('Губы', Icons.mood_rounded),
    ('Нос', Icons.air_rounded),
    ('Одежда', Icons.checkroom_rounded),
    ('Глаза', Icons.remove_red_eye_rounded),
    ('Очки', Icons.visibility_outlined),
    ('Борода', Icons.face_retouching_natural_rounded),
    ('Жест', Icons.pan_tool_rounded),
  ];

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProfileNotifierProvider).valueOrNull;
    if (user != null && user.characterStateJson.isNotEmpty) {
      _config = AvatarConfig.fromJsonString(user.characterStateJson);
    } else {
      _config = const AvatarConfig();
    }
  }

  Future<void> _save() async {
    HapticFeedback.mediumImpact();
    try {
      final isar = await ref.read(isarProvider.future);
      final local = await isar.userProfileLocals.where().findFirst();
      if (local != null) {
        Map<String, dynamic> existing = {};
        try {
          existing =
              jsonDecode(local.characterStateJson) as Map<String, dynamic>;
        } catch (_) {}
        final merged = _config.toJson();
        if (existing.containsKey('painPoints')) {
          merged['painPoints'] = existing['painPoints'];
        }
        local.characterStateJson = jsonEncode(merged);
        await isar.writeTxn(() async {
          await isar.userProfileLocals.put(local);
        });
      }
    } catch (_) {}
    ref.invalidate(userProfileNotifierProvider);
    if (mounted) Navigator.of(context).pop(_config);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileNotifierProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(onClose: () => Navigator.of(context).pop(), onSave: _save),
            const SizedBox(height: 10),
            _ReflectionStage(config: _config, user: user),
            const SizedBox(height: 14),
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _sections.length,
                itemBuilder: (context, index) {
                  final isActive = index == _currentSection;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _currentSection = index);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.textPrimary
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(999),
                        border: isActive
                            ? null
                            : Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _sections[index].$2,
                            size: 14,
                            color: isActive
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _sections[index].$1,
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isActive
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _buildSection(_currentSection, user),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(int index, UserProfile? user) {
    return switch (index) {
      0 => _buildPresetGrid(user),
      1 => _buildStyleGrid(
          key: 'background',
          options: AvatarConfig.backgroundOptions,
          selected: _config.backgroundId,
          user: user,
          onSelect: (id) =>
              setState(() => _config = _config.copyWith(backgroundId: id)),
        ),
      2 => _buildStyleGrid(
          key: 'frame',
          options: AvatarConfig.frameOptions,
          selected: _config.frameId,
          user: user,
          onSelect: (id) =>
              setState(() => _config = _config.copyWith(frameId: id)),
        ),
      3 => _buildStyleGrid(
          key: 'aura',
          options: AvatarConfig.auraOptions,
          selected: _config.auraId,
          user: user,
          onSelect: (id) =>
              setState(() => _config = _config.copyWith(auraId: id)),
        ),
      4 => _buildStyleGrid(
          key: 'badge',
          options: AvatarConfig.badgeOptions,
          selected: _config.badgeId,
          user: user,
          onSelect: (id) =>
              setState(() => _config = _config.copyWith(badgeId: id)),
        ),
      5 => _buildPresetGridForField(
          key: 'hair',
          presets: AvatarConfig.hairPresets,
          selected: _config.hair,
          onSelect: (v) => setState(() => _config = _config.copyWith(hair: v)),
        ),
      6 => _buildPresetGridForField(
          key: 'brows',
          presets: AvatarConfig.browsPresets,
          selected: _config.brows,
          onSelect: (v) => setState(() => _config = _config.copyWith(brows: v)),
        ),
      7 => _buildPresetGridForField(
          key: 'lips',
          presets: AvatarConfig.lipsPresets,
          selected: _config.lips,
          onSelect: (v) => setState(() => _config = _config.copyWith(lips: v)),
        ),
      8 => _buildPresetGridForField(
          key: 'nose',
          presets: AvatarConfig.nosePresets,
          selected: _config.nose,
          onSelect: (v) => setState(() => _config = _config.copyWith(nose: v)),
        ),
      9 => _buildPresetGridForField(
          key: 'body',
          presets: AvatarConfig.bodyPresets,
          selected: _config.body,
          onSelect: (v) => setState(() => _config = _config.copyWith(body: v)),
        ),
      10 => _buildSequentialGrid(
          key: 'eyes',
          count: 5,
          selected: _config.eyes,
          onSelect: (v) => setState(() => _config = _config.copyWith(eyes: v)),
        ),
      11 => _buildOptionalGrid(
          key: 'glasses',
          count: AvatarConfig.glassesCount,
          selected: _config.glasses,
          onSelect: (v) =>
              setState(() => _config = _config.copyWith(glasses: v)),
          noneLabel: 'Без очков',
        ),
      12 => _buildOptionalGrid(
          key: 'beard',
          count: AvatarConfig.beardCount,
          selected: _config.beard,
          onSelect: (v) => setState(() => _config = _config.copyWith(beard: v)),
          noneLabel: 'Без бороды',
        ),
      13 => _buildGestureGrid(),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildPresetGrid(UserProfile? user) {
    return GridView.builder(
      key: const ValueKey('presets'),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: AvatarConfig.presets.length,
      itemBuilder: (context, i) {
        final preset = AvatarConfig.presets[i];
        final unlocked = _isUnlocked(
          user,
          requiredLevel: preset.requiredLevel,
          requiredStreak: preset.requiredStreak,
        );
        return _ReflectionTile(
          title: preset.title,
          subtitle: preset.subtitle,
          selected: _sameStyle(_config, preset.config),
          locked: !unlocked,
          requirement: _requirement(
            requiredLevel: preset.requiredLevel,
            requiredStreak: preset.requiredStreak,
          ),
          onTap: () {
            if (!unlocked) return _lockedTap();
            HapticFeedback.selectionClick();
            setState(() => _config = preset.config);
          },
          child: AvatarWidget(
            config: preset.config,
            size: 88,
            streak: user?.currentStreak ?? 0,
          ),
        );
      },
    );
  }

  Widget _buildStyleGrid({
    required String key,
    required List<AvatarStyleOption> options,
    required String selected,
    required UserProfile? user,
    required void Function(String) onSelect,
  }) {
    return GridView.builder(
      key: ValueKey(key),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      itemCount: options.length,
      itemBuilder: (context, i) {
        final option = options[i];
        final unlocked = _isUnlocked(
          user,
          requiredLevel: option.requiredLevel,
          requiredStreak: option.requiredStreak,
        );
        final preview = _applyStyle(key, option.id);
        return _ReflectionTile(
          title: option.title,
          subtitle: option.subtitle,
          selected: option.id == selected,
          locked: !unlocked,
          requirement: _requirement(
            requiredLevel: option.requiredLevel,
            requiredStreak: option.requiredStreak,
          ),
          onTap: () {
            if (!unlocked) return _lockedTap();
            HapticFeedback.selectionClick();
            onSelect(option.id);
          },
          child: AvatarWidget(
            config: preview,
            size: 86,
            streak: user?.currentStreak ?? 0,
          ),
        );
      },
    );
  }

  Widget _buildPresetGridForField({
    required String key,
    required List<int> presets,
    required int selected,
    required void Function(int) onSelect,
  }) {
    return GridView.builder(
      key: ValueKey(key),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: presets.length,
      itemBuilder: (context, i) {
        final value = presets[i];
        return _OptionTile(
          isActive: value == selected,
          onTap: () {
            HapticFeedback.selectionClick();
            onSelect(value);
          },
          child: _MiniAvatar(config: _applyField(key, value), size: 54),
        );
      },
    );
  }

  Widget _buildSequentialGrid({
    required String key,
    required int count,
    required int selected,
    required void Function(int) onSelect,
  }) {
    return GridView.builder(
      key: ValueKey(key),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: count,
      itemBuilder: (context, i) {
        return _OptionTile(
          isActive: i == selected,
          onTap: () {
            HapticFeedback.selectionClick();
            onSelect(i);
          },
          child: _MiniAvatar(config: _applyField(key, i), size: 54),
        );
      },
    );
  }

  Widget _buildOptionalGrid({
    required String key,
    required int count,
    required int selected,
    required void Function(int) onSelect,
    required String noneLabel,
  }) {
    return GridView.builder(
      key: ValueKey(key),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: count + 1,
      itemBuilder: (context, i) {
        final value = i == 0 ? -1 : i - 1;
        if (i == 0) {
          return _OptionTile(
            isActive: value == selected,
            onTap: () {
              HapticFeedback.selectionClick();
              onSelect(-1);
            },
            child: Center(
              child: Text(
                noneLabel,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: value == selected
                      ? Colors.white
                      : AppColors.textSecondary,
                ),
              ),
            ),
          );
        }
        return _OptionTile(
          isActive: value == selected,
          onTap: () {
            HapticFeedback.selectionClick();
            onSelect(value);
          },
          child: _MiniAvatar(config: _applyField(key, value), size: 54),
        );
      },
    );
  }

  Widget _buildGestureGrid() {
    return GridView.builder(
      key: const ValueKey('gesture'),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.55,
      ),
      itemCount: AvatarConfig.gestureNames.length,
      itemBuilder: (context, i) {
        final value = i == 0 ? -1 : i - 1;
        return _OptionTile(
          isActive: value == _config.gesture,
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _config = _config.copyWith(gesture: value));
          },
          child: Center(
            child: Text(
              AvatarConfig.gestureNames[i],
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: value == _config.gesture
                    ? Colors.white
                    : AppColors.textSecondary,
              ),
            ),
          ),
        );
      },
    );
  }

  AvatarConfig _applyStyle(String field, String id) {
    return switch (field) {
      'background' => _config.copyWith(backgroundId: id),
      'frame' => _config.copyWith(frameId: id),
      'aura' => _config.copyWith(auraId: id),
      'badge' => _config.copyWith(badgeId: id),
      _ => _config,
    };
  }

  AvatarConfig _applyField(String field, int value) {
    return switch (field) {
      'hair' => _config.copyWith(hair: value),
      'brows' => _config.copyWith(brows: value),
      'lips' => _config.copyWith(lips: value),
      'nose' => _config.copyWith(nose: value),
      'body' => _config.copyWith(body: value),
      'eyes' => _config.copyWith(eyes: value),
      'glasses' => _config.copyWith(glasses: value),
      'beard' => _config.copyWith(beard: value),
      _ => _config,
    };
  }

  bool _sameStyle(AvatarConfig a, AvatarConfig b) {
    return a.backgroundId == b.backgroundId &&
        a.frameId == b.frameId &&
        a.auraId == b.auraId &&
        a.badgeId == b.badgeId;
  }

  bool _isUnlocked(
    UserProfile? user, {
    required int requiredLevel,
    required int requiredStreak,
  }) {
    final level = user?.level ?? 1;
    final streak = user?.currentStreak ?? 0;
    return level >= requiredLevel && streak >= requiredStreak;
  }

  String _requirement(
      {required int requiredLevel, required int requiredStreak}) {
    if (requiredStreak > 0) return '$requiredStreak дней подряд';
    if (requiredLevel > 1) return 'Уровень $requiredLevel';
    return 'Открыто';
  }

  void _lockedTap() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Система пока не зафиксировала это изменение.',
          style: GoogleFonts.dmSans(fontSize: 14),
        ),
        backgroundColor: AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onSave;

  const _TopBar({required this.onClose, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close,
                size: 22, color: AppColors.textSecondary),
          ),
          const Spacer(),
          Column(
            children: [
              Text(
                'Отражение',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 22,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'облик твоего пути',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: AppColors.textDisabled,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const Spacer(),
          TextButton(
            onPressed: onSave,
            child: Text(
              'Готово',
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.gold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReflectionStage extends StatelessWidget {
  final AvatarConfig config;
  final UserProfile? user;

  const _ReflectionStage({required this.config, required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            AvatarWidget(
              config: config,
              size: 132,
              streak: user?.currentStreak ?? 0,
              showBorder: true,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name.isNotEmpty == true ? user!.name : 'Путник',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 23,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Уровень ${user?.level ?? 1} · ${user?.currentStreak ?? 0} дн. ритма',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Награды не покупаются. Они появляются, когда путь зафиксирован.',
                    style: GoogleFonts.dmSans(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReflectionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final bool locked;
  final String requirement;
  final VoidCallback onTap;
  final Widget child;

  const _ReflectionTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.locked,
    required this.requirement,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.gold : AppColors.divider,
            width: selected ? 1.6 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.18),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: Opacity(
                  opacity: locked ? 0.42 : 1,
                  child: child,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (locked)
                  const Icon(Icons.lock_rounded,
                      size: 14, color: AppColors.textDisabled)
                else if (selected)
                  const Icon(Icons.check_circle_rounded,
                      size: 15, color: AppColors.gold),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              locked ? requirement : subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color:
                    locked ? AppColors.textDisabled : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;
  final Widget child;

  const _OptionTile({
    required this.isActive,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: isActive ? AppColors.textPrimary : AppColors.surface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isActive ? AppColors.gold : AppColors.divider,
            width: isActive ? 2 : 1,
          ),
        ),
        child: child,
      ),
    );
  }
}

class _MiniAvatar extends StatelessWidget {
  final AvatarConfig config;
  final double size;

  const _MiniAvatar({required this.config, required this.size});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AvatarWidget(
        config: config,
        size: size,
        showBorder: false,
      ),
    );
  }
}
