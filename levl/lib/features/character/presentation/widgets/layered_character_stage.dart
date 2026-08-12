import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/character_asset_manifest.dart';

class LayeredCharacterStage extends StatelessWidget {
  const LayeredCharacterStage({
    super.key,
    required this.manifest,
    required this.view,
    this.fit = BoxFit.contain,
  });

  final CharacterAssetManifest manifest;
  final CharacterView view;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final layers = manifest.layersFor(view);
    if (layers.isEmpty) {
      return const Center(
        child: Icon(
          Icons.person_outline_rounded,
          size: 52,
          color: AppColors.textDisabled,
        ),
      );
    }

    return Semantics(
      image: true,
      label: 'Полноразмерный персонаж, ${_viewLabel(view)}',
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          for (final layer in layers)
            RepaintBoundary(
              key: ValueKey('${view.name}-${layer.slot.name}'),
              child: Image.asset(
                layer.assetPath,
                fit: fit,
                filterQuality: FilterQuality.high,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.textDisabled,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

String _viewLabel(CharacterView view) => switch (view) {
      CharacterView.front => 'вид спереди',
      CharacterView.frontThreeQuarter => 'поворот на три четверти',
      CharacterView.side => 'вид сбоку',
      CharacterView.backThreeQuarter => 'поворот со спины',
      CharacterView.back => 'вид сзади',
    };
