class TimerItem {
  final String id;
  final String title;
  final Duration duration;
  final bool isCompleted;

  const TimerItem({
    required this.id,
    required this.title,
    required this.duration,
    this.isCompleted = false,
  });

  TimerItem copyWith({
    String? id,
    String? title,
    Duration? duration,
    bool? isCompleted,
  }) {
    return TimerItem(
      id: id ?? this.id,
      title: title ?? this.title,
      duration: duration ?? this.duration,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'durationMinutes': duration.inMinutes,
      'isCompleted': isCompleted,
    };
  }

  factory TimerItem.fromJson(Map<String, dynamic> json) {
    return TimerItem(
      id: json['id'] as String,
      title: json['title'] as String,
      duration: Duration(minutes: json['durationMinutes'] as int),
      isCompleted: json['isCompleted'] as bool,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimerItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          duration == other.duration &&
          isCompleted == other.isCompleted;

  @override
  int get hashCode =>
      id.hashCode ^ title.hashCode ^ duration.hashCode ^ isCompleted.hashCode;
}

class PomodoroState {
  final List<TimerItem> queue;
  final int currentIndex;
  final Duration timeLeft;
  final bool isRunning;

  const PomodoroState({
    required this.queue,
    required this.currentIndex,
    required this.timeLeft,
    required this.isRunning,
  });

  PomodoroState copyWith({
    List<TimerItem>? queue,
    int? currentIndex,
    Duration? timeLeft,
    bool? isRunning,
  }) {
    return PomodoroState(
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      timeLeft: timeLeft ?? this.timeLeft,
      isRunning: isRunning ?? this.isRunning,
    );
  }
}
