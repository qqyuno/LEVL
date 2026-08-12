import 'package:flutter_test/flutter_test.dart';
import 'package:levl/features/character/domain/character_asset_manifest.dart';

void main() {
  test('layer assets render in the stable production order', () {
    const manifest = CharacterAssetManifest(
      views: {
        CharacterView.front: [
          CharacterLayerAsset(
            slot: CharacterLayerSlot.accessory,
            assetPath: 'accessory.png',
          ),
          CharacterLayerAsset(
            slot: CharacterLayerSlot.body,
            assetPath: 'body.png',
          ),
          CharacterLayerAsset(
            slot: CharacterLayerSlot.upper,
            assetPath: 'upper.png',
          ),
        ],
      },
    );

    expect(
      manifest.layersFor(CharacterView.front).map((layer) => layer.slot),
      [
        CharacterLayerSlot.body,
        CharacterLayerSlot.upper,
        CharacterLayerSlot.accessory,
      ],
    );
  });
}
