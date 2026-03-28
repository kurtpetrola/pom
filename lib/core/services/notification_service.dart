import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  static const int _immediateNotificationId = 0;
  static const int _scheduledNotificationId = 1;
  static const int _ongoingNotificationId = 2;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidConfig = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinConfig = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidConfig,
      iOS: darwinConfig,
    );
    await _plugin.initialize(settings: initSettings);

    // Request notification permission on Android 13+ (API 33+)
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }
  }

  Future<void> showSessionCompleteNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'pomodoro_channel',
      'Pomodoro Timer',
      channelDescription: 'Notifications for Pomodoro timer completion',
      importance: Importance.max,
      priority: Priority.high,
    );
    const darwinDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _plugin.show(
      id: _immediateNotificationId,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }

  /// Schedule a notification at [endTime] for when the timer completes in the background.
  Future<void> scheduleTimerNotification({
    required DateTime endTime,
    required String timerTitle,
  }) async {
    final scheduledDate = tz.TZDateTime.from(endTime, tz.local);

    // Don't schedule if the time is already in the past
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    const androidDetails = AndroidNotificationDetails(
      'pomodoro_channel',
      'Pomodoro Timer',
      channelDescription: 'Notifications for Pomodoro timer completion',
      importance: Importance.max,
      priority: Priority.high,
    );
    const darwinDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _plugin.zonedSchedule(
      id: _scheduledNotificationId,
      title: 'Timer Complete',
      body: '$timerTitle is finished!',
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Show a silent ongoing notification with a live countdown while the app is
  /// minimized and a timer is running.
  ///
  /// Uses Android's native chronometer in countdown mode so the notification
  /// updates automatically with zero Dart engine overhead.
  Future<void> showOngoingTimerNotification({
    required String timerTitle,
    required DateTime endTime,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'pomodoro_ongoing_channel_v2',
      'Timer Progress',
      channelDescription: 'Shows active timer progress while app is minimized',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      ongoing: true,
      autoCancel: false,
      showWhen: true,
      usesChronometer: true,
      chronometerCountDown: true,
      when: endTime.millisecondsSinceEpoch,
      playSound: false,
      enableVibration: false,
      silent: true,
      visibility: NotificationVisibility.public,
    );
    final details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      id: _ongoingNotificationId,
      title: timerTitle,
      body: 'Timer running',
      notificationDetails: details,
    );
  }

  /// Cancel the ongoing timer notification.
  Future<void> cancelOngoingNotification() async {
    await _plugin.cancel(id: _ongoingNotificationId);
  }

  /// Cancel any scheduled background notification.
  Future<void> cancelScheduledNotifications() async {
    await _plugin.cancel(id: _scheduledNotificationId);
  }

  /// Cancel all notifications (ongoing + scheduled).
  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }
}
