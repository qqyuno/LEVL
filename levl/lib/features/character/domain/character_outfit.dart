import 'character_asset_manifest.dart';

enum CharacterOutfitRarity { standard, uncommon, rare, epic }

class CharacterOutfit {
  const CharacterOutfit({
    required this.id,
    required this.title,
    required this.description,
    required this.rarity,
    required this.manifest,
    this.requiredLevel = 1,
    this.requiredStreak = 0,
  });

  final String id;
  final String title;
  final String description;
  final CharacterOutfitRarity rarity;
  final CharacterAssetManifest manifest;
  final int requiredLevel;
  final int requiredStreak;

  bool isUnlocked({required int level, required int streak}) {
    return level >= requiredLevel && streak >= requiredStreak;
  }

  String get rewardLabel {
    if (requiredStreak > 0) return '$requiredStreak дней';
    if (requiredLevel > 1) return 'Ур. $requiredLevel';
    return 'Старт';
  }
}

abstract class CharacterWardrobe {
  static const outfits = <CharacterOutfit>[
    CharacterOutfit(
      id: 'focus',
      title: 'Фокус',
      description: 'Чистая база',
      rarity: CharacterOutfitRarity.standard,
      manifest: CharacterAssetManifest(
        views: {
          CharacterView.front: [
            CharacterLayerAsset(
              slot: CharacterLayerSlot.composite,
              assetPath:
                  'assets/character_v2/body/levl_body_male_front_base_v1.png',
            ),
          ],
        },
      ),
    ),
    CharacterOutfit(
      id: 'momentum',
      title: 'Движение',
      description: 'Спокойный ритм',
      rarity: CharacterOutfitRarity.uncommon,
      requiredLevel: 2,
      manifest: CharacterAssetManifest(
        views: {
          CharacterView.front: [
            CharacterLayerAsset(
              slot: CharacterLayerSlot.composite,
              assetPath:
                  'assets/character_v2/body/levl_body_male_front_momentum_v1.png',
            ),
          ],
        },
      ),
    ),
    CharacterOutfit(
      id: 'operator',
      title: 'Оператор',
      description: 'Собранный режим',
      rarity: CharacterOutfitRarity.rare,
      requiredLevel: 4,
      manifest: CharacterAssetManifest(
        views: {
          CharacterView.front: [
            CharacterLayerAsset(
              slot: CharacterLayerSlot.composite,
              assetPath:
                  'assets/character_v2/body/levl_body_male_front_operator_v1.png',
            ),
          ],
        },
      ),
    ),
    CharacterOutfit(
      id: 'breakthrough',
      title: 'Прорыв',
      description: 'Награда за ритм',
      rarity: CharacterOutfitRarity.epic,
      requiredStreak: 7,
      manifest: CharacterAssetManifest(
        views: {
          CharacterView.front: [
            CharacterLayerAsset(
              slot: CharacterLayerSlot.composite,
              assetPath:
                  'assets/character_v2/body/levl_body_male_front_breakthrough_v1.png',
            ),
          ],
        },
      ),
    ),
  ];

  static CharacterOutfit byId(String id) {
    return outfits.firstWhere(
      (outfit) => outfit.id == id,
      orElse: () => outfits.first,
    );
  }

  static String idForIndex(int index) {
    if (index < 0 || index >= outfits.length) return outfits.first.id;
    return outfits[index].id;
  }

  static int indexForId(String id) {
    final index = outfits.indexWhere((outfit) => outfit.id == id);
    return index < 0 ? 0 : index;
  }
}
