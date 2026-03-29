import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../shared/models/user_model.dart';
import '../../shared/models/quest_model.dart';

part 'isar_service.g.dart';

/// Global Isar instance — opened once at app startup.
/// keepAlive: true so it's never disposed during the session.
@Riverpod(keepAlive: true)
Future<Isar> isar(IsarRef ref) async {
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [UserProfileLocalSchema, QuestLocalSchema],
    directory: dir.path,
    inspector: true,
  );
  return isar;
}
