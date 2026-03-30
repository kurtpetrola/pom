import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'core/services/app_lifecycle_observer.dart';
import 'core/services/notification_service.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/application/settings_controller.dart';
import 'features/timer/presentation/timer_screen.dart';

/// Main entry point for the application.
/// Initializes required services before running the app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone data and set local timezone (required for scheduled notifications)
  tz_data.initializeTimeZones();
  final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));

  // Initialize shared preferences synchronously before runApp
  final prefs = await SharedPreferences.getInstance();

  // Initialize notification plugin so alerts work on all platforms
  final notificationService = NotificationService();
  await notificationService.init();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const PomodoroApp(),
    ),
  );
}

/// Root widget of the application, listens to settings provider
/// to dynamically rebuild theme changes.
class PomodoroApp extends ConsumerWidget {
  const PomodoroApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final primaryColor = AppTheme.getColorFromName(settings.themeColor);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pom',
      theme: AppTheme.getTheme(primaryColor),
      home: const AppLifecycleObserver(child: TimerScreen()),
    );
  }
}
