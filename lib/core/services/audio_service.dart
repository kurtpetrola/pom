import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService();
});

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playAlert() async {
    await _player.play(AssetSource('sounds/alert.mp3'));
  }

  void dispose() {
    _player.dispose();
  }
}
