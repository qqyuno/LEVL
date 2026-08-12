import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/user_model.dart';
import '../../../dashboard/presentation/providers/quest_provider.dart';
import '../../domain/character_asset_manifest.dart';
import '../widgets/layered_character_stage.dart';
import 'avatar_editor_screen.dart';

class FullBodyEditorScreen extends ConsumerWidget {
  const FullBodyEditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileNotifierProvider).valueOrNull;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FullBodyEditorContent(
          user: user,
          onClose: () => Navigator.of(context).pop(),
          onEditFace: () => Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(builder: (_) => const AvatarEditorScreen()),
          ),
        ),
      ),
    );
  }
}

class FullBodyEditorContent extends StatelessWidget {
  const FullBodyEditorContent({
    super.key,
    required this.user,
    required this.onClose,
    required this.onEditFace,
  });

  final UserProfile? user;
  final VoidCallback onClose;
  final VoidCallback onEditFace;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StudioHeader(onClose: onClose),
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
                      const Positioned.fill(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                          child: LayeredCharacterStage(
                            manifest: CharacterAssetManifest.pilot,
                            view: CharacterView.front,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 12,
                        top: 12,
                        child: _StageLabel(
                          level: user?.level ?? 1,
                          streak: user?.currentStreak ?? 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        _StudioControls(
          user: user,
          onEditFace: onEditFace,
        ),
      ],
    );
  }
}

class _StudioHeader extends StatelessWidget {
  const _StudioHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
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
                  'Базовый силуэт',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: AppColors.textDisabled,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.view_in_ar_outlined,
            size: 20,
            color: AppColors.textSecondary,
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
    required this.user,
    required this.onEditFace,
  });

  final UserProfile? user;
  final VoidCallback onEditFace;

  @override
  Widget build(BuildContext context) {
    final name = user?.name.trim();
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name?.isNotEmpty == true ? name! : 'Твой персонаж',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Основа 01 · фронтальный вид',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: onEditFace,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.textPrimary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.face_retouching_natural, size: 18),
                  label: const Text('Лицо'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
