/// Data class representing the user's customizable settings for the Pomodoro app.
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
      shortBreakDurationMinutes:
          shortBreakDurationMinutes ?? this.shortBreakDurationMinutes,
      longBreakDurationMinutes:
          longBreakDurationMinutes ?? this.longBreakDurationMinutes,
      themeColor: themeColor ?? this.themeColor,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      confirmBeforeNextTimer:
          confirmBeforeNextTimer ?? this.confirmBeforeNextTimer,
      playSoundWhenCompleted:
          playSoundWhenCompleted ?? this.playSoundWhenCompleted,
    );
  }
}
