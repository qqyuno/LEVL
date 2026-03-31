import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audio_service.g.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playQuestComplete() => _play('assets/sounds/quest_complete.mp3');
  Future<void> playLevelUp()       => _play('assets/sounds/level_up.mp3');
  Future<void> playUiTap()         => _play('assets/sounds/ui_tap.mp3');

  Future<void> _play(String asset) async {
    try {
      await _player.setAsset(asset);
      await _player.seek(Duration.zero);
      await _player.play();
    } catch (_) {
      // Звук не критичен — молча проглатываем ошибку
    }
  }

  void dispose() => _player.dispose();
}

@Riverpod(keepAlive: true)
AudioService audioService(Ref ref) {
  final service = AudioService();
  ref.onDispose(service.dispose);
  return service;
}
