import 'package:flutter_test/flutter_test.dart';
import 'package:levl/features/character/domain/character_asset_manifest.dart';
import 'package:levl/features/character/domain/character_outfit.dart';

void main() {
  test('wardrobe exposes four aligned front outfits', () {
    expect(CharacterWardrobe.outfits, hasLength(4));
    for (final outfit in CharacterWardrobe.outfits) {
      expect(outfit.manifest.supports(CharacterView.front), isTrue);
      expect(outfit.manifest.supports(CharacterView.side), isFalse);
    }
  });

  test('reward requirements unlock outfits predictably', () {
    final momentum = CharacterWardrobe.byId('momentum');
    final operator = CharacterWardrobe.byId('operator');
    final breakthrough = CharacterWardrobe.byId('breakthrough');

    expect(momentum.isUnlocked(level: 1, streak: 0), isFalse);
    expect(momentum.isUnlocked(level: 2, streak: 0), isTrue);
    expect(operator.isUnlocked(level: 3, streak: 30), isFalse);
    expect(operator.isUnlocked(level: 4, streak: 0), isTrue);
    expect(breakthrough.isUnlocked(level: 20, streak: 6), isFalse);
    expect(breakthrough.isUnlocked(level: 1, streak: 7), isTrue);
  });

  test('outfit ids map safely to persisted indices', () {
    expect(CharacterWardrobe.indexForId('operator'), 2);
    expect(CharacterWardrobe.idForIndex(2), 'operator');
    expect(CharacterWardrobe.idForIndex(99), 'focus');
    expect(CharacterWardrobe.indexForId('unknown'), 0);
  });
}
