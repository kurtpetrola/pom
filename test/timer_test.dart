import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pom/features/timer/application/timer_controller.dart';
import 'package:pom/core/services/audio_service.dart';
import 'package:pom/core/services/notification_service.dart';
import 'package:pom/core/services/storage_service.dart';

class MockAudioService extends AudioService {
  @override
  Future<void> playAlert() async {}
}

class MockNotificationService extends NotificationService {
  @override
  Future<void> showSessionCompleteNotification({required String title, required String body}) async {}

  @override
  Future<void> scheduleTimerNotification({required DateTime endTime, required String timerTitle}) async {}

  @override
  Future<void> cancelScheduledNotifications() async {}
}

void main() {
  test('Timer queue initializes correctly', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        audioServiceProvider.overrideWith((ref) => MockAudioService()),
        notificationServiceProvider.overrideWith((ref) => MockNotificationService()),
      ],
    );

    // Initial state has default queue
    expect(container.read(timerControllerProvider).queue.isNotEmpty, true);
    expect(container.read(timerControllerProvider).currentIndex, 0);
  });
}
