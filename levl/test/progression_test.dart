import 'package:flutter_test/flutter_test.dart';
import 'package:levl/shared/models/user_model.dart';

void main() {
  group('level progression', () {
    test('starts at level 1 with zero XP', () {
      expect(levelFromXp(0), 1);
      expect(levelProgress(0, 1), 0);
    });

    test('uses the nonlinear XP curve', () {
      expect(xpToNextLevel(1), 200);
      expect(xpToNextLevel(5), 600);
      expect(levelFromXp(199), 1);
      expect(levelFromXp(200), 2);
      expect(levelFromXp(500), 3);
    });
  });
}
