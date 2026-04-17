import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../features/settings/application/settings_controller.dart';
import '../../features/timer/application/timer_controller.dart';

/// Provider that initializes the KeepDisplayOnService.
/// This is a provider that simply exists to listen to changes and side-effect.
final keepDisplayOnProvider = Provider<void>((ref) {
  final settings = ref.watch(settingsControllerProvider);
  final timerState = ref.watch(timerControllerProvider);

  final shouldKeepOn = settings.keepDisplayOn && timerState.isRunning;

  // We use a Future to avoid issues with calling a platform channel during build
  // although WakelockPlus.toggle is generally safe, it's good practice.
  Future.microtask(() {
    WakelockPlus.toggle(enable: shouldKeepOn);
  });
});
