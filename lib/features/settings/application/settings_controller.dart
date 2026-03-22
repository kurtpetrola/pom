import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/storage_service.dart';

class PomodoroSettings {
  final int workDurationMinutes;
  final int shortBreakDurationMinutes;
  final int longBreakDurationMinutes;
  final String themeColor;
  final bool enableNotifications;
  final bool confirmBeforeNextTimer;
  final bool playSoundWhenCompleted;

  const PomodoroSettings({
    required this.workDurationMinutes,
    required this.shortBreakDurationMinutes,
    required this.longBreakDurationMinutes,
    this.themeColor = 'Green',
    this.enableNotifications = true,
    this.confirmBeforeNextTimer = true,
    this.playSoundWhenCompleted = true,
  });

  PomodoroSettings copyWith({
    int? workDurationMinutes,
    int? shortBreakDurationMinutes,
    int? longBreakDurationMinutes,
    String? themeColor,
    bool? enableNotifications,
    bool? confirmBeforeNextTimer,
    bool? playSoundWhenCompleted,
  }) {
    return PomodoroSettings(
      workDurationMinutes: workDurationMinutes ?? this.workDurationMinutes,
      shortBreakDurationMinutes: shortBreakDurationMinutes ?? this.shortBreakDurationMinutes,
      longBreakDurationMinutes: longBreakDurationMinutes ?? this.longBreakDurationMinutes,
      themeColor: themeColor ?? this.themeColor,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      confirmBeforeNextTimer: confirmBeforeNextTimer ?? this.confirmBeforeNextTimer,
      playSoundWhenCompleted: playSoundWhenCompleted ?? this.playSoundWhenCompleted,
    );
  }
}

final settingsControllerProvider = NotifierProvider<SettingsController, PomodoroSettings>(SettingsController.new);
final settingsProvider = settingsControllerProvider;

class SettingsController extends Notifier<PomodoroSettings> {
  @override
  PomodoroSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return PomodoroSettings(
      workDurationMinutes: prefs.getInt('workDurationMinutes') ?? 25,
      shortBreakDurationMinutes: prefs.getInt('shortBreakDurationMinutes') ?? 5,
      longBreakDurationMinutes: prefs.getInt('longBreakDurationMinutes') ?? 15,
      themeColor: prefs.getString('themeColor') ?? 'Green',
      enableNotifications: prefs.getBool('enableNotifications') ?? true,
      confirmBeforeNextTimer: prefs.getBool('confirmBeforeNextTimer') ?? true,
      playSoundWhenCompleted: prefs.getBool('playSoundWhenCompleted') ?? true,
    );
  }

  void updateThemeColor(String color) {
    ref.read(sharedPreferencesProvider).setString('themeColor', color);
    state = state.copyWith(themeColor: color);
  }

  void updateNotifications(bool enabled) {
    ref.read(sharedPreferencesProvider).setBool('enableNotifications', enabled);
    state = state.copyWith(enableNotifications: enabled);
  }

  void updateConfirmation(bool enabled) {
    ref.read(sharedPreferencesProvider).setBool('confirmBeforeNextTimer', enabled);
    state = state.copyWith(confirmBeforeNextTimer: enabled);
  }

  void updateSound(bool enabled) {
    ref.read(sharedPreferencesProvider).setBool('playSoundWhenCompleted', enabled);
    state = state.copyWith(playSoundWhenCompleted: enabled);
  }

  // Keep existing methods for backward compatibility or future use if needed, 
  // though they are not in the primary UI now.
  void updateWorkDuration(int minutes) {
    ref.read(sharedPreferencesProvider).setInt('workDurationMinutes', minutes);
    state = state.copyWith(workDurationMinutes: minutes);
  }

  void resetPomodoroSettings() {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setInt('workDurationMinutes', 25);
    prefs.setInt('shortBreakDurationMinutes', 5);
    prefs.setInt('longBreakDurationMinutes', 15);
    
    state = state.copyWith(
      workDurationMinutes: 25,
      shortBreakDurationMinutes: 5,
      longBreakDurationMinutes: 15,
    );
  }
}
