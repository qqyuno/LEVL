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
import '../../../../shared/widgets/premium_face_avatar_widget.dart';
import '../../../dashboard/presentation/providers/quest_provider.dart';

class AvatarEditorScreen extends ConsumerStatefulWidget {
  const AvatarEditorScreen({super.key});

  @override
  ConsumerState<AvatarEditorScreen> createState() => _AvatarEditorScreenState();
}

class _AvatarEditorScreenState extends ConsumerState<AvatarEditorScreen> {
  late AvatarConfig _config;
  late AvatarConfig _initialConfig;
  int _currentSection = 0;

  static const _sections = [
    ('Прическа', Icons.face_rounded),
    ('Цвет волос', Icons.palette_rounded),
    ('Тон кожи', Icons.tonality_rounded),
    ('Брови', Icons.face_retouching_natural_rounded),
    ('Цвет глаз', Icons.visibility_rounded),
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
    _initialConfig = _config;
  }

  void _reset() {
    HapticFeedback.selectionClick();
    setState(() => _config = _initialConfig);
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
            _TopBar(
              onClose: () => Navigator.of(context).pop(),
              onReset: _reset,
              onSave: _save,
            ),
            const SizedBox(height: 10),
            _ReflectionStage(
              config: _config,
              user: user,
            ),
            const SizedBox(height: 14),
            _CategoryRail(
              sections: _sections,
              selectedIndex: _currentSection,
              onSelected: (index) {
                HapticFeedback.selectionClick();
                setState(() => _currentSection = index);
              },
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _sections[_currentSection].$1,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
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
      0 => _buildSequentialGrid(
          key: 'hair',
          count: AvatarConfig.premiumHairStyleCount,
          selected: _config.hair % AvatarConfig.premiumHairStyleCount,
          onSelect: (v) => setState(() => _config = _config.copyWith(hair: v)),
        ),
      1 => _buildSequentialGrid(
          key: 'hairColor',
          count: AvatarConfig.hairColorCount,
          selected: _config.hairColor,
          onSelect: (v) =>
              setState(() => _config = _config.copyWith(hairColor: v)),
        ),
      2 => _buildSequentialGrid(
          key: 'skinTone',
          count: AvatarConfig.premiumSkinToneCount,
          selected: _config.skinTone % AvatarConfig.premiumSkinToneCount,
          onSelect: (v) =>
              setState(() => _config = _config.copyWith(skinTone: v)),
        ),
      3 => _buildSequentialGrid(
          key: 'brows',
          count: AvatarConfig.premiumBrowStyleCount,
          selected: _config.brows % AvatarConfig.premiumBrowStyleCount,
          onSelect: (v) => setState(() => _config = _config.copyWith(brows: v)),
        ),
      4 => _buildSequentialGrid(
          key: 'eyeColor',
          count: AvatarConfig.eyeColorCount,
          selected: _config.eyeColor,
          onSelect: (v) =>
              setState(() => _config = _config.copyWith(eyeColor: v)),
        ),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildSequentialGrid({
    required String key,
    required int count,
    required int selected,
    required void Function(int) onSelect,
  }) {
    final columns = count <= 3 ? count : 2;
    return GridView.builder(
      key: ValueKey(key),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: count <= 3 ? 0.68 : 0.78,
      ),
      itemCount: count,
      itemBuilder: (context, i) {
        return _OptionTile(
          isActive: i == selected,
          onTap: () {
            HapticFeedback.selectionClick();
            onSelect(i);
          },
          child: _FaceOptionPreview(
            config: _applyField(key, i),
            size: count <= 3 ? 94 : 112,
            label: _optionLabel(key, i),
            swatch: _optionSwatch(key, i),
            isActive: i == selected,
          ),
        );
      },
    );
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
      'faceShape' => _config.copyWith(faceShape: value),
      'skinTone' => _config.copyWith(skinTone: value),
      'bodyType' => _config.copyWith(bodyType: value),
      'top' => _config.copyWith(top: value),
      'pants' => _config.copyWith(pants: value),
      'shoes' => _config.copyWith(shoes: value),
      'accessory' => _config.copyWith(accessory: value),
      'expression' => _config.copyWith(expression: value),
      'viewAngle' => _config.copyWith(viewAngle: value),
      'hairColor' => _config.copyWith(hairColor: value),
      'eyeColor' => _config.copyWith(eyeColor: value),
      _ => _config,
    };
  }

  String _optionLabel(String key, int value) {
    return switch (key) {
      'hair' => const [
          'Объем',
          'Кроп',
          'Пробор',
          'Buzz',
          'Slick',
          'Кудри',
        ][value],
      'hairColor' => const ['Графит', 'Брюнет', 'Каштан'][value],
      'skinTone' => const [
          'Светлый',
          'Натуральный',
          'Теплый',
          'Глубокий',
        ][value],
      'brows' => const ['Естественные', 'Прямые', 'Густые', 'Собранные'][value],
      'eyeColor' => const ['Карие', 'Серо-синие', 'Зеленые'][value],
      _ => '${value + 1}',
    };
  }

  Color? _optionSwatch(String key, int value) {
    return switch (key) {
      'hairColor' => const [
          Color(0xFF141211),
          Color(0xFF3B261A),
          Color(0xFF6B3F22),
        ][value],
      'skinTone' => const [
          Color(0xFFE2B28F),
          Color(0xFFC58E68),
          Color(0xFFA96F4E),
          Color(0xFF754A36),
        ][value],
      'eyeColor' => const [
          Color(0xFF6A4A32),
          Color(0xFF4F8098),
          Color(0xFF527956),
        ][value],
      _ => null,
    };
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onReset;
  final VoidCallback onSave;

  const _TopBar({
    required this.onClose,
    required this.onReset,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: const Icon(
              Icons.close,
              size: 22,
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Студия персонажа',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 22,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'собери свой облик',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: AppColors.textDisabled,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Сбросить изменения',
            onPressed: onReset,
            icon: const Icon(
              Icons.restart_alt_rounded,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ),
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

class _CategoryRail extends StatelessWidget {
  final List<(String, IconData)> sections;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _CategoryRail({
    required this.sections,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(sections.length, (index) {
          final selected = index == selectedIndex;
          return Expanded(
            child: Tooltip(
              message: sections[index].$1,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => onSelected(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 50,
                  margin: EdgeInsets.only(
                      right: index == sections.length - 1 ? 0 : 6),
                  decoration: BoxDecoration(
                    color:
                        selected ? AppColors.textPrimary : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    sections[index].$2,
                    size: 19,
                    color: selected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _ReflectionStage extends StatelessWidget {
  final AvatarConfig config;
  final UserProfile? user;

  const _ReflectionStage({
    required this.config,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: PremiumFaceAvatarWidget(
                key: ValueKey(config.toJsonString()),
                config: config,
                size: 210,
                level: user?.level ?? 1,
                streak: user?.currentStreak ?? 0,
              ),
            ),
            const SizedBox(height: 12),
            _StageText(user: user, centered: true),
          ],
        ),
      ),
    );
  }
}

class _StageText extends StatelessWidget {
  final UserProfile? user;
  final bool centered;

  const _StageText({
    required this.user,
    required this.centered,
  });

  @override
  Widget build(BuildContext context) {
    final align = centered ? TextAlign.center : TextAlign.start;
    return Column(
      crossAxisAlignment:
          centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          user?.name.isNotEmpty == true ? user!.name : 'Путник',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: align,
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 23,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Уровень ${user?.level ?? 1} · ${user?.currentStreak ?? 0} дн. ритма',
          textAlign: align,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.gold,
          ),
        ),
      ],
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

class _FaceOptionPreview extends StatelessWidget {
  final AvatarConfig config;
  final double size;
  final String label;
  final Color? swatch;
  final bool isActive;

  const _FaceOptionPreview({
    required this.config,
    required this.size,
    required this.label,
    required this.swatch,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = isActive ? Colors.white : AppColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 7),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  _MiniAvatar(config: config, size: size),
                  if (swatch != null)
                    Positioned(
                      right: 3,
                      top: 4,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: swatch,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isActive
                                ? AppColors.gold
                                : AppColors.background,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: foreground,
            ),
          ),
        ],
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
      child: PremiumFaceAvatarWidget(
        config: config,
        size: size,
        showFrame: false,
        compact: true,
        animate: false,
      ),
    );
  }
}
