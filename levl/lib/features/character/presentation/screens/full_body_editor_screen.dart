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
import '../../../dashboard/presentation/providers/quest_provider.dart';
import '../../domain/character_asset_manifest.dart';
import '../../domain/character_outfit.dart';
import '../widgets/layered_character_stage.dart';
import '../widgets/outfit_wardrobe_rail.dart';
import 'avatar_editor_screen.dart';

class FullBodyEditorScreen extends ConsumerWidget {
  const FullBodyEditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileNotifierProvider).valueOrNull;
    final config = user?.characterStateJson.isNotEmpty == true
        ? AvatarConfig.fromJsonString(user!.characterStateJson)
        : const AvatarConfig();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FullBodyEditorContent(
          user: user,
          equippedOutfitId: CharacterWardrobe.idForIndex(config.top),
          onClose: () => Navigator.of(context).pop(),
          onEditFace: () => Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(builder: (_) => const AvatarEditorScreen()),
          ),
          onEquip: (outfitId) => _persistOutfit(ref, outfitId),
        ),
      ),
    );
  }

  Future<void> _persistOutfit(WidgetRef ref, String outfitId) async {
    final isar = await ref.read(isarProvider.future);
    final local = await isar.userProfileLocals.where().findFirst();
    if (local == null) {
      throw StateError('Local profile is unavailable');
    }

    Map<String, dynamic> state = {};
    try {
      state = jsonDecode(local.characterStateJson) as Map<String, dynamic>;
    } catch (_) {}

    final config =
        AvatarConfig.fromJsonString(local.characterStateJson).copyWith(
      top: CharacterWardrobe.indexForId(outfitId),
    );
    state.addAll(config.toJson());
    local.characterStateJson = jsonEncode(state);
    await isar.writeTxn(() async => isar.userProfileLocals.put(local));
    ref.invalidate(userProfileNotifierProvider);
  }
}

class FullBodyEditorContent extends StatefulWidget {
  const FullBodyEditorContent({
    super.key,
    required this.user,
    required this.onClose,
    required this.onEditFace,
    this.equippedOutfitId = 'focus',
    this.onEquip,
  });

  final UserProfile? user;
  final VoidCallback onClose;
  final VoidCallback onEditFace;
  final String equippedOutfitId;
  final Future<void> Function(String outfitId)? onEquip;

  @override
  State<FullBodyEditorContent> createState() => _FullBodyEditorContentState();
}

class _FullBodyEditorContentState extends State<FullBodyEditorContent> {
  late String _previewedOutfitId;
  late String _equippedOutfitId;
  bool _isSaving = false;

  int get _level => widget.user?.level ?? 1;
  int get _streak => widget.user?.currentStreak ?? 0;

  @override
  void initState() {
    super.initState();
    _equippedOutfitId = CharacterWardrobe.byId(widget.equippedOutfitId).id;
    _previewedOutfitId = _equippedOutfitId;
  }

  @override
  void didUpdateWidget(covariant FullBodyEditorContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.equippedOutfitId != widget.equippedOutfitId) {
      _equippedOutfitId = CharacterWardrobe.byId(widget.equippedOutfitId).id;
    }
  }

  Future<void> _equip(CharacterOutfit outfit) async {
    if (_isSaving || !outfit.isUnlocked(level: _level, streak: _streak)) {
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() => _isSaving = true);
    try {
      await widget.onEquip?.call(outfit.id);
      if (mounted) setState(() => _equippedOutfitId = outfit.id);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось сохранить образ')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final outfit = CharacterWardrobe.byId(_previewedOutfitId);
    final unlocked = outfit.isUnlocked(level: _level, streak: _streak);
    return Column(
      children: [
        _StudioHeader(
          onClose: widget.onClose,
          onEditFace: widget.onEditFace,
        ),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            switchInCurve: Curves.easeOut,
                            child: LayeredCharacterStage(
                              key: ValueKey(outfit.id),
                              manifest: outfit.manifest,
                              view: CharacterView.front,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 12,
                        top: 12,
                        child: _StageLabel(level: _level, streak: _streak),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        _StudioControls(
          outfit: outfit,
          equipped: outfit.id == _equippedOutfitId,
          unlocked: unlocked,
          saving: _isSaving,
          level: _level,
          streak: _streak,
          onSelected: (selected) {
            HapticFeedback.selectionClick();
            setState(() => _previewedOutfitId = selected.id);
          },
          onEquip: () => _equip(outfit),
        ),
      ],
    );
  }
}

class _StudioHeader extends StatelessWidget {
  const _StudioHeader({required this.onClose, required this.onEditFace});

  final VoidCallback onClose;
  final VoidCallback onEditFace;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Закрыть студию',
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Студия образа',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 23,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Одежда отражает прогресс',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: AppColors.textDisabled,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onEditFace,
            icon: const Icon(Icons.face_retouching_natural, size: 18),
            label: const Text('Лицо'),
          ),
        ],
      ),
    );
  }
}

class _StageLabel extends StatelessWidget {
  const _StageLabel({required this.level, required this.streak});

  final int level;
  final int streak;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        child: Text(
          'УР. $level  ·  РИТМ $streak',
          style: GoogleFonts.dmSans(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: AppColors.surface,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }
}

class _StudioControls extends StatelessWidget {
  const _StudioControls({
    required this.outfit,
    required this.equipped,
    required this.unlocked,
    required this.saving,
    required this.level,
    required this.streak,
    required this.onSelected,
    required this.onEquip,
  });

  final CharacterOutfit outfit;
  final bool equipped;
  final bool unlocked;
  final bool saving;
  final int level;
  final int streak;
  final ValueChanged<CharacterOutfit> onSelected;
  final VoidCallback onEquip;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Column(
            children: [
              OutfitWardrobeRail(
                outfits: CharacterWardrobe.outfits,
                selectedId: outfit.id,
                level: level,
                streak: streak,
                onSelected: onSelected,
              ),
              const SizedBox(height: 11),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          outfit.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          unlocked ? outfit.description : outfit.rewardLabel,
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            color: unlocked
                                ? AppColors.textSecondary
                                : AppColors.textDisabled,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 42,
                    child: FilledButton.icon(
                      key: const ValueKey('equip-outfit'),
                      onPressed:
                          unlocked && !equipped && !saving ? onEquip : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.textPrimary,
                        disabledBackgroundColor: AppColors.surfaceElevated,
                        disabledForegroundColor: AppColors.textSecondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: Icon(
                        unlocked
                            ? (equipped
                                ? Icons.check_rounded
                                : Icons.checkroom_rounded)
                            : Icons.lock_outline_rounded,
                        size: 17,
                      ),
                      label: Text(
                        saving
                            ? 'Сохраняем'
                            : equipped
                                ? 'Надето'
                                : unlocked
                                    ? 'Надеть'
                                    : outfit.rewardLabel,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
