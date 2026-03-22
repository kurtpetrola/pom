import 'package:flutter_riverpod/flutter_riverpod.dart';

final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService();
});

class AudioService {
  Future<void> playAlert() async {
    // Expected to play alert.mp3 here.
  }
}
