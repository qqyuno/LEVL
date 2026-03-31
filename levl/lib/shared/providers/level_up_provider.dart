import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'level_up_provider.g.dart';

/// Хранит новый уровень при level-up событии.
/// null = нет активного события.
@Riverpod(keepAlive: true)
class LevelUpNotifier extends _$LevelUpNotifier {
  @override
  int? build() => null;

  void trigger(int newLevel) => state = newLevel;
  void dismiss() => state = null;
}
