import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for accessing the [AudioService] instance across the app.
final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService();
});

/// Service responsible for handling audio playback, such as timer alerts.
class AudioService {
  final AudioPlayer _player = AudioPlayer();

  /// Plays the designated alert sound (e.g., when a timer completes).
  Future<void> playAlert() async {
    await _player.play(AssetSource('sounds/alert.mp3'));
  }

  /// Cleans up the player resources when the service is no longer needed.
  void dispose() {
    _player.dispose();
  }
}
