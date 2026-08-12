enum CharacterView {
  front,
  frontThreeQuarter,
  side,
  backThreeQuarter,
  back,
}

enum CharacterLayerSlot {
  composite,
  body,
  lower,
  shoes,
  upper,
  hair,
  accessory,
  effect,
}

class CharacterLayerAsset {
  const CharacterLayerAsset({
    required this.slot,
    required this.assetPath,
  });

  final CharacterLayerSlot slot;
  final String assetPath;
}

class CharacterAssetManifest {
  const CharacterAssetManifest({required this.views});

  final Map<CharacterView, List<CharacterLayerAsset>> views;

  bool supports(CharacterView view) => views[view]?.isNotEmpty == true;

  List<CharacterLayerAsset> layersFor(CharacterView view) {
    final layers = List<CharacterLayerAsset>.from(
      views[view] ?? const <CharacterLayerAsset>[],
    );
    layers.sort((a, b) => a.slot.index.compareTo(b.slot.index));
    return layers;
  }

  static const pilot = CharacterAssetManifest(
    views: {
      CharacterView.front: [
        CharacterLayerAsset(
          slot: CharacterLayerSlot.composite,
          assetPath:
              'assets/character_v2/body/levl_body_male_front_base_v1.png',
        ),
      ],
    },
  );
}
