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
            _ReflectionStage(
              config: _config,
              user: user,
              sectionIndex: _currentSection,
            ),
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

  bool _sameStyle(AvatarConfig a, AvatarConfig b) {
    return a.toJsonString() == b.toJsonString();
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

  String _requirement({
    required int requiredLevel,
    required int requiredStreak,
  }) {
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
            icon: const Icon(
              Icons.close,
              size: 22,
              color: AppColors.textSecondary,
            ),
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
  final int sectionIndex;

  const _ReflectionStage({
    required this.config,
    required this.user,
    required this.sectionIndex,
  });

  @override
  Widget build(BuildContext context) {
    final isFaceDetail = sectionIndex >= 2;
    final hint = switch (sectionIndex) {
      0 => 'Силуэт должен читаться сразу, без лишнего шума.',
      1 => 'Натуральный тон волос без грязи на коже.',
      2 => 'Тон меняет кожу, сохраняя естественный свет и текстуру.',
      3 => 'Форма бровей меняет характер, но остается естественной.',
      4 => 'Цвет глаз показан крупнее, чтобы выбор был заметен.',
      _ => 'Облик фиксирует путь.',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(20, isFaceDetail ? 16 : 18, 20, 18),
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
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: isFaceDetail
              ? Column(
                  key: ValueKey('face-detail-stage-$sectionIndex'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PremiumFaceAvatarWidget(
                      config: config,
                      size: 188,
                      level: user?.level ?? 1,
                      streak: user?.currentStreak ?? 0,
                    ),
                    const SizedBox(height: 12),
                    _StageText(user: user, hint: hint, centered: true),
                  ],
                )
              : Row(
                  key: const ValueKey('default-stage'),
                  children: [
                    PremiumFaceAvatarWidget(
                      config: config,
                      size: 154,
                      level: user?.level ?? 1,
                      streak: user?.currentStreak ?? 0,
                      compact: true,
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: _StageText(
                        user: user,
                        hint: hint,
                        centered: false,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _StageText extends StatelessWidget {
  final UserProfile? user;
  final String hint;
  final bool centered;

  const _StageText({
    required this.user,
    required this.hint,
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
        const SizedBox(height: 10),
        Text(
          hint,
          textAlign: align,
          style: GoogleFonts.dmSans(
            fontSize: 12.5,
            color: AppColors.textSecondary,
            height: 1.35,
          ),
        ),
      ],
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
                child: Opacity(opacity: locked ? 0.42 : 1, child: child),
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
                  const Icon(
                    Icons.lock_rounded,
                    size: 14,
                    color: AppColors.textDisabled,
                  )
                else if (selected)
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 15,
                    color: AppColors.gold,
                  ),
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
