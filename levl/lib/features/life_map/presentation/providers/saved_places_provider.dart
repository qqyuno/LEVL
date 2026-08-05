import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/supabase/isar_service.dart';
import '../../../../shared/models/user_model.dart';
import '../../application/device_location_service.dart';
import '../../domain/saved_place.dart';

part 'saved_places_provider.g.dart';

@Riverpod(keepAlive: true)
class SavedPlacesNotifier extends _$SavedPlacesNotifier {
  @override
  Future<List<SavedPlaceLocal>> build() async {
    final isar = await ref.watch(isarProvider.future);
    return _readPlaces(isar, await _currentUserId(isar));
  }

  Future<String?> saveCurrentPlace({
    required SavedPlaceType type,
    required String name,
  }) async {
    final previous = state.valueOrNull ?? const <SavedPlaceLocal>[];
    state = const AsyncLoading();

    try {
      final position = await const DeviceLocationService().currentPoint();
      final isar = await ref.read(isarProvider.future);
      final profile = await isar.userProfileLocals.where().findFirst();
      final userId = profile?.supabaseId ?? 'local';
      final place = SavedPlaceLocal()
        ..userId = userId
        ..name = name.trim().isEmpty ? type.defaultName : name.trim()
        ..type = type
        ..latitude = position.latitude
        ..longitude = position.longitude;

      await isar.writeTxn(() async {
        await isar.savedPlaceLocals.put(place);
      });
      state = AsyncData(await _readPlaces(isar, userId));
      return null;
    } on DeviceLocationException catch (error) {
      state = AsyncData(previous);
      return error.message;
    } catch (_) {
      state = AsyncData(previous);
      return 'Не удалось определить точку. Выйди ближе к окну и повтори.';
    }
  }

  Future<void> removePlace(Id id) async {
    final isar = await ref.read(isarProvider.future);
    await isar.writeTxn(() => isar.savedPlaceLocals.delete(id));
    state = AsyncData(await _readPlaces(isar, await _currentUserId(isar)));
  }

  Future<List<SavedPlaceLocal>> _readPlaces(Isar isar, String userId) async {
    final places =
        await isar.savedPlaceLocals.filter().userIdEqualTo(userId).findAll();
    places.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return places;
  }

  Future<String> _currentUserId(Isar isar) async {
    final profile = await isar.userProfileLocals.where().findFirst();
    return profile?.supabaseId ?? 'local';
  }
}
