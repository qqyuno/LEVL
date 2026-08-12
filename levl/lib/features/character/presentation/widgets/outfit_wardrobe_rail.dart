import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/character_asset_manifest.dart';
import '../../domain/character_outfit.dart';

class OutfitWardrobeRail extends StatelessWidget {
  const OutfitWardrobeRail({
    super.key,
    required this.outfits,
    required this.selectedId,
    required this.level,
    required this.streak,
    required this.onSelected,
  });

  final List<CharacterOutfit> outfits;
  final String selectedId;
  final int level;
  final int streak;
  final ValueChanged<CharacterOutfit> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Гардероб',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              'Награды за прогресс',
              style: GoogleFonts.dmSans(
                fontSize: 10,
                color: AppColors.textDisabled,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: outfits.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final outfit = outfits[index];
              return _OutfitCard(
                key: ValueKey('outfit-${outfit.id}'),
                outfit: outfit,
                selected: outfit.id == selectedId,
                unlocked: outfit.isUnlocked(level: level, streak: streak),
                onTap: () => onSelected(outfit),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _OutfitCard extends StatelessWidget {
  const _OutfitCard({
    super.key,
    required this.outfit,
    required this.selected,
    required this.unlocked,
    required this.onTap,
  });

  final CharacterOutfit outfit;
  final bool selected;
  final bool unlocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final preview = outfit.manifest.layersFor(CharacterView.front).first;
    final accent = _rarityColor(outfit.rarity);
    return Semantics(
      button: true,
      selected: selected,
      label: '${outfit.title}, ${unlocked ? 'доступно' : outfit.rewardLabel}',
      child: SizedBox(
        width: 142,
        child: Material(
          color: selected ? AppColors.surfaceElevated : AppColors.surface,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: selected ? AppColors.textPrimary : AppColors.divider,
              width: selected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Row(
              children: [
                Container(width: 3, color: accent),
                SizedBox(
                  width: 48,
                  height: double.infinity,
                  child: Image.asset(
                    preview.assetPath,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    cacheWidth: 112,
                    filterQuality: FilterQuality.medium,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(9, 9, 7, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          outfit.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(
                              unlocked
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.lock_outline_rounded,
                              size: 13,
                              color: unlocked ? accent : AppColors.textDisabled,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                outfit.rewardLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.dmSans(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: unlocked
                                      ? AppColors.textSecondary
                                      : AppColors.textDisabled,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Color _rarityColor(CharacterOutfitRarity rarity) => switch (rarity) {
      CharacterOutfitRarity.standard => AppColors.textDisabled,
      CharacterOutfitRarity.uncommon => AppColors.sphereKnowledge,
      CharacterOutfitRarity.rare => AppColors.gold,
      CharacterOutfitRarity.epic => AppColors.sphereWill,
    };
