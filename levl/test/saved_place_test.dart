import 'package:flutter_test/flutter_test.dart';
import 'package:levl/features/life_map/domain/saved_place.dart';

void main() {
  group('SavedPlaceLocal', () {
    late SavedPlaceLocal place;

    setUp(() {
      place = SavedPlaceLocal()
        ..userId = 'user'
        ..name = 'Мой зал'
        ..type = SavedPlaceType.training
        ..latitude = 55.751244
        ..longitude = 37.618423
        ..radiusMeters = 150;
    });

    test('accepts coordinates inside configured radius', () {
      expect(place.containsCoordinates(55.751700, 37.618423), isTrue);
    });

    test('rejects coordinates outside configured radius', () {
      expect(place.containsCoordinates(55.754000, 37.618423), isFalse);
    });

    test('distance to the same point is zero', () {
      expect(
          place.distanceTo(place.latitude, place.longitude), closeTo(0, .01));
    });
  });
}
