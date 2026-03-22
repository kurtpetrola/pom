import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/application/settings_controller.dart';
import 'features/timer/presentation/timer_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize shared preferences synchronously before runApp
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const PomodoroApp(),
    ),
  );
}

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
      home: const TimerScreen(),
    );
  }
}

