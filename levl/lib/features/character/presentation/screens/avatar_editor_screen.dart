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
    ('Волосы', Icons.face),
    ('Брови', Icons.visibility),
    ('Губы', Icons.mood),
    ('Нос', Icons.air),
    ('Одежда', Icons.checkroom),
    ('Глаза', Icons.remove_red_eye),
    ('Очки', Icons.visibility_outlined),
    ('Борода', Icons.face_retouching_natural),
    ('Жест', Icons.pan_tool),
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
        // Preserve pain points stored by onboarding in the same JSON field
        Map<String, dynamic> existing = {};
        try {
          existing = jsonDecode(local.characterStateJson) as Map<String, dynamic>;
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // --- Top bar ---
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 22, color: AppColors.textSecondary),
                  ),
                  const Spacer(),
                  Text(
                    'Настройка аватара',
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _save,
                    child: Text(
                      'Готово',
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // --- Avatar preview ---
            Expanded(
              flex: 4,
              child: Center(
                child: AvatarWidget(
                  config: _config,
                  size: 200,
                  showBorder: true,
                ),
              ),
            ),

            // --- Section tabs ---
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
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.textPrimary : AppColors.surface,
                        borderRadius: BorderRadius.circular(100),
                        border: isActive ? null : Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _sections[index].$2,
                            size: 14,
                            color: isActive ? Colors.white : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _sections[index].$1,
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isActive ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // --- Options grid ---
            Expanded(
              flex: 3,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _buildSection(_currentSection),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(int index) {
    switch (index) {
      case 0:
        return _buildPresetGrid(
          key: 'hair',
          presets: AvatarConfig.hairPresets,
          selected: _config.hair,
          onSelect: (v) => setState(() => _config = _config.copyWith(hair: v)),
        );
      case 1:
        return _buildPresetGrid(
          key: 'brows',
          presets: AvatarConfig.browsPresets,
          selected: _config.brows,
          onSelect: (v) => setState(() => _config = _config.copyWith(brows: v)),
        );
      case 2:
        return _buildPresetGrid(
          key: 'lips',
          presets: AvatarConfig.lipsPresets,
          selected: _config.lips,
          onSelect: (v) => setState(() => _config = _config.copyWith(lips: v)),
        );
      case 3:
        return _buildPresetGrid(
          key: 'nose',
          presets: AvatarConfig.nosePresets,
          selected: _config.nose,
          onSelect: (v) => setState(() => _config = _config.copyWith(nose: v)),
        );
      case 4:
        return _buildPresetGrid(
          key: 'body',
          presets: AvatarConfig.bodyPresets,
          selected: _config.body,
          onSelect: (v) => setState(() => _config = _config.copyWith(body: v)),
        );
      case 5:
        return _buildSequentialGrid(
          key: 'eyes',
          count: 5,
          selected: _config.eyes,
          onSelect: (v) => setState(() => _config = _config.copyWith(eyes: v)),
        );
      case 6:
        return _buildOptionalGrid(
          key: 'glasses',
          count: AvatarConfig.glassesCount,
          selected: _config.glasses,
          onSelect: (v) => setState(() => _config = _config.copyWith(glasses: v)),
          noneLabel: 'Без очков',
        );
      case 7:
        return _buildOptionalGrid(
          key: 'beard',
          count: AvatarConfig.beardCount,
          selected: _config.beard,
          onSelect: (v) => setState(() => _config = _config.copyWith(beard: v)),
          noneLabel: 'Без бороды',
        );
      case 8:
        return _buildGestureGrid();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPresetGrid({
    required String key,
    required List<int> presets,
    required int selected,
    required void Function(int) onSelect,
  }) {
    return GridView.builder(
      key: ValueKey(key),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: presets.length,
      itemBuilder: (context, i) {
        final value = presets[i];
        final isActive = value == selected;
        return _OptionTile(
          isActive: isActive,
          onTap: () {
            HapticFeedback.selectionClick();
            onSelect(value);
          },
          child: _MiniAvatar(
            config: _applyField(key, value),
            size: 52,
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: count,
      itemBuilder: (context, i) {
        final isActive = i == selected;
        return _OptionTile(
          isActive: isActive,
          onTap: () {
            HapticFeedback.selectionClick();
            onSelect(i);
          },
          child: _MiniAvatar(
            config: _applyField(key, i),
            size: 52,
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: count + 1,
      itemBuilder: (context, i) {
        final value = i == 0 ? -1 : i - 1;
        final isActive = value == selected;

        if (i == 0) {
          return _OptionTile(
            isActive: isActive,
            onTap: () {
              HapticFeedback.selectionClick();
              onSelect(-1);
            },
            child: Center(
              child: Text(
                noneLabel,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return _OptionTile(
          isActive: isActive,
          onTap: () {
            HapticFeedback.selectionClick();
            onSelect(value);
          },
          child: _MiniAvatar(
            config: _applyField(key, value),
            size: 52,
          ),
        );
      },
    );
  }

  Widget _buildGestureGrid() {
    return GridView.builder(
      key: const ValueKey('gesture'),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.6,
      ),
      itemCount: AvatarConfig.gestureNames.length,
      itemBuilder: (context, i) {
        final value = i == 0 ? -1 : i - 1;
        final isActive = value == _config.gesture;

        return _OptionTile(
          isActive: isActive,
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _config = _config.copyWith(gesture: value));
          },
          child: Center(
            child: Text(
              AvatarConfig.gestureNames[i],
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }

  AvatarConfig _applyField(String field, int value) {
    switch (field) {
      case 'hair':
        return _config.copyWith(hair: value);
      case 'brows':
        return _config.copyWith(brows: value);
      case 'lips':
        return _config.copyWith(lips: value);
      case 'nose':
        return _config.copyWith(nose: value);
      case 'body':
        return _config.copyWith(body: value);
      case 'eyes':
        return _config.copyWith(eyes: value);
      case 'glasses':
        return _config.copyWith(glasses: value);
      case 'beard':
        return _config.copyWith(beard: value);
      default:
        return _config;
    }
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
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isActive ? AppColors.textPrimary : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: isActive
              ? Border.all(color: AppColors.gold, width: 2)
              : Border.all(color: AppColors.divider),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AvatarWidget(
        config: config,
        size: size,
        showBorder: false,
      ),
    );
  }
}
