import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/application/settings_controller.dart';
import '../../features/timer/application/timer_controller.dart';
import '../services/notification_service.dart';

/// Observes app lifecycle changes to schedule/cancel background notifications.
///
/// When the app goes to the background with a running timer, a notification
/// is scheduled at the timer's end time. When the app returns, it's cancelled.
class AppLifecycleObserver extends ConsumerStatefulWidget {
  final Widget child;

  const AppLifecycleObserver({super.key, required this.child});

  @override
  ConsumerState<AppLifecycleObserver> createState() =>
      _AppLifecycleObserverState();
}

class _AppLifecycleObserverState extends ConsumerState<AppLifecycleObserver>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final notificationService = ref.read(notificationServiceProvider);
    final settings = ref.read(settingsControllerProvider);

    if (state == AppLifecycleState.paused) {
      // App going to background — show ongoing notification & schedule
      // completion notification if timer is running.
      if (!settings.enableNotifications) return;

      final timerState = ref.read(timerControllerProvider);
      if (timerState.isRunning && timerState.endTime != null) {
        final currentItem = timerState.currentIndex < timerState.queue.length
            ? timerState.queue[timerState.currentIndex]
            : null;
        if (currentItem != null) {
          // Silent ongoing notification with live countdown (Android only)
          notificationService.showOngoingTimerNotification(
            timerTitle: currentItem.title,
            endTime: timerState.endTime!,
          );

          // Scheduled "timer complete" notification at the end time
          notificationService.scheduleTimerNotification(
            endTime: timerState.endTime!,
            timerTitle: currentItem.title,
          );
        }
      }
    } else if (state == AppLifecycleState.resumed) {
      // App returning to foreground — cancel background notifications
      notificationService.cancelOngoingNotification();
      notificationService.cancelScheduledNotifications();
    } else if (state == AppLifecycleState.detached) {
      // App fully closed — cancel everything
      notificationService.cancelAllNotifications();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
