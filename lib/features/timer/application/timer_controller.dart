import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/services/audio_service.dart';
import '../../../../core/services/clock_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../settings/application/settings_controller.dart';
import '../domain/timer_state.dart';

final timerControllerProvider = NotifierProvider<TimerController, PomodoroState>(TimerController.new);

class TimerController extends Notifier<PomodoroState> {
  static const String _queuePrefsKey = 'timesets_queue';
  Timer? _ticker;
  DateTime? _targetTime;
  final Uuid _uuid = const Uuid();

  @override
  PomodoroState build() {
    return _loadInitialState();
  }

  PomodoroState _loadInitialState() {
    final prefs = ref.read(sharedPreferencesProvider);
    final queueJsonStr = prefs.getString(_queuePrefsKey);

    List<TimerItem> initialQueue;
    if (queueJsonStr != null) {
      try {
        final List<dynamic> decoded = jsonDecode(queueJsonStr);
        initialQueue = decoded.map((e) => TimerItem.fromJson(e as Map<String, dynamic>)).toList();
      } catch (e) {
        initialQueue = _generateDefaultQueue();
      }
    } else {
      initialQueue = _generateDefaultQueue();
    }

    if (initialQueue.isEmpty) {
      initialQueue = _generateDefaultQueue();
    }

    // Reset completion status on load
    initialQueue = initialQueue.map((t) => t.copyWith(isCompleted: false)).toList();

    return PomodoroState(
      queue: initialQueue,
      currentIndex: 0,
      timeLeft: initialQueue.first.duration,
      isRunning: false,
    );
  }

  List<TimerItem> _generateDefaultQueue() {
    return [
      TimerItem(id: _uuid.v4(), title: 'Work Phase', duration: const Duration(minutes: 25)),
      TimerItem(id: _uuid.v4(), title: 'Short Break', duration: const Duration(minutes: 5)),
      TimerItem(id: _uuid.v4(), title: 'Work Phase', duration: const Duration(minutes: 25)),
      TimerItem(id: _uuid.v4(), title: 'Short Break', duration: const Duration(minutes: 5)),
      TimerItem(id: _uuid.v4(), title: 'Work Review', duration: const Duration(minutes: 15)),
      TimerItem(id: _uuid.v4(), title: 'Long Break', duration: const Duration(minutes: 15)),
    ];
  }

  void _saveQueue(List<TimerItem> queue) {
    final prefs = ref.read(sharedPreferencesProvider);
    final jsonList = queue.map((t) => t.toJson()).toList();
    prefs.setString(_queuePrefsKey, jsonEncode(jsonList));
  }

  void toggleTimer() {
    if (state.queue.isEmpty) return;
    
    if (state.isRunning) {
      pause();
    } else {
      if (state.currentIndex >= state.queue.length) {
        // Queue is completely finished. Reset it.
        resetQueue();
        start();
      } else {
        start();
      }
    }
  }

  void start() {
    if (state.isRunning || state.currentIndex >= state.queue.length) return;

    final now = ref.read(clockProvider)();
    _targetTime = now.add(state.timeLeft);
    state = state.copyWith(isRunning: true);

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      final currentNow = ref.read(clockProvider)();
      if (_targetTime!.isBefore(currentNow) || _targetTime!.isAtSameMomentAs(currentNow)) {
        _completePhase();
      } else {
        state = state.copyWith(timeLeft: _targetTime!.difference(currentNow));
      }
    });
  }

  void pause() {
    if (!state.isRunning) return;
    _ticker?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void reset() {
    _ticker?.cancel();
    if (state.queue.isEmpty) {
      state = state.copyWith(isRunning: false, timeLeft: Duration.zero);
      return;
    }
    
    // Reset the current timer back to its full original duration
    final currentItem = state.queue.length > state.currentIndex 
      ? state.queue[state.currentIndex] 
      : state.queue.last;

    state = state.copyWith(
      timeLeft: currentItem.duration,
      isRunning: false,
    );
  }

  void resetQueue() {
    _ticker?.cancel();
    
    final resetItems = state.queue.map((t) => t.copyWith(isCompleted: false)).toList();
    _saveQueue(resetItems);
    
    state = PomodoroState(
      queue: resetItems,
      currentIndex: 0,
      timeLeft: resetItems.isNotEmpty ? resetItems.first.duration : Duration.zero,
      isRunning: false,
    );
  }

  void _completePhase() {
    _ticker?.cancel();

    final settings = ref.read(settingsControllerProvider);

    if (settings.playSoundWhenCompleted) {
      ref.read(audioServiceProvider).playAlert();
    }
    
    if (settings.enableNotifications) {
      final currentItem = state.queue[state.currentIndex];
      ref.read(notificationServiceProvider).showSessionCompleteNotification(
        title: 'Timer Complete',
        body: '${currentItem.title} is finished!',
      );
    }

    // Mark current item complete
    final updatedQueue = List<TimerItem>.from(state.queue);
    updatedQueue[state.currentIndex] = updatedQueue[state.currentIndex].copyWith(isCompleted: true);
    
    final nextIndex = state.currentIndex + 1;
    
    if (nextIndex < updatedQueue.length) {
      // Check if we should auto-start or wait for confirmation
      final shouldAutoStart = !settings.confirmBeforeNextTimer;
      
      state = PomodoroState(
        queue: updatedQueue,
        currentIndex: nextIndex,
        timeLeft: updatedQueue[nextIndex].duration,
        isRunning: false,
      );

      if (shouldAutoStart) {
        start();
      }
    } else {
      // Queue is fully complete
      state = PomodoroState(
        queue: updatedQueue,
        currentIndex: nextIndex,
        timeLeft: Duration.zero,
        isRunning: false,
      );
    }
    
    _saveQueue(updatedQueue);
  }

  void updateTimerDuration(int index, Duration newDuration) {
    if (index < 0 || index >= state.queue.length) return;
    
    final updatedQueue = List<TimerItem>.from(state.queue);
    updatedQueue[index] = updatedQueue[index].copyWith(duration: newDuration);
    
    // If updating current uncompleted timer while paused, also visually update timeLeft
    if (index == state.currentIndex && !state.isRunning && !updatedQueue[index].isCompleted) {
       state = state.copyWith(timeLeft: newDuration, queue: updatedQueue);
    } else {
       state = state.copyWith(queue: updatedQueue);
    }
    
    _saveQueue(updatedQueue);
  }

  void expirePhaseForTesting() {
    _completePhase();
  }

  // Playlist Management Methods
  
  void addTimer(String title, Duration duration) {
    final newItem = TimerItem(
      id: _uuid.v4(),
      title: title,
      duration: duration,
    );
    
    final newQueue = List<TimerItem>.from(state.queue)..add(newItem);
    _saveQueue(newQueue);
    
    if (state.currentIndex >= state.queue.length) {
      // If queue was finished, and we added one, move back to it
      state = state.copyWith(
        queue: newQueue,
        currentIndex: newQueue.length - 1,
        timeLeft: duration,
      );
    } else {
      state = state.copyWith(queue: newQueue);
    }
  }

  void removeTimer(int index) {
    if (index < 0 || index >= state.queue.length) return;
    
    final newQueue = List<TimerItem>.from(state.queue)..removeAt(index);
    _saveQueue(newQueue);
    
    // If we removed the currently running/paused timer
    if (index == state.currentIndex) {
      _ticker?.cancel();
      int newIndex = state.currentIndex;
      if (newIndex >= newQueue.length) {
        newIndex = newQueue.length - 1;
      }
      
      if (newIndex >= 0) {
        state = PomodoroState(
          queue: newQueue,
          currentIndex: newIndex,
          timeLeft: newQueue[newIndex].duration,
          isRunning: false,
        );
      } else {
        state = PomodoroState(
          queue: newQueue,
          currentIndex: 0,
          timeLeft: Duration.zero,
          isRunning: false,
        );
      }
    } else if (index < state.currentIndex) {
      // If we removed a timer before the current one, decrement current index
      state = state.copyWith(
        queue: newQueue,
        currentIndex: state.currentIndex - 1,
      );
    } else {
      // Removed a timer after current
      state = state.copyWith(queue: newQueue);
    }
  }

  void reorderTimers(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    
    final newQueue = List<TimerItem>.from(state.queue);
    final item = newQueue.removeAt(oldIndex);
    newQueue.insert(newIndex, item);
    _saveQueue(newQueue);

    int updatedCurrentIndex = state.currentIndex;
    Duration updatedTimeLeft = state.timeLeft;

    if (state.isRunning) {
      if (oldIndex == state.currentIndex) {
        updatedCurrentIndex = newIndex;
      } else if (oldIndex < state.currentIndex && newIndex >= state.currentIndex) {
        updatedCurrentIndex--;
      } else if (oldIndex > state.currentIndex && newIndex <= state.currentIndex) {
        updatedCurrentIndex++;
      }
    } else {
      // If paused, we don't automatically follow the moved item.
      // This ensures we prioritize what the user dragged to the active position (like index 0).
      bool itemAtCurrentSlotChanged = false;
      if (oldIndex == state.currentIndex) {
        itemAtCurrentSlotChanged = true;
      } else if (oldIndex < state.currentIndex && newIndex >= state.currentIndex) {
        itemAtCurrentSlotChanged = true;
      } else if (oldIndex > state.currentIndex && newIndex <= state.currentIndex) {
        itemAtCurrentSlotChanged = true;
      }
      
      if (itemAtCurrentSlotChanged && state.currentIndex < newQueue.length) {
        updatedTimeLeft = newQueue[state.currentIndex].duration;
      }
    }

    state = state.copyWith(
      queue: newQueue,
      currentIndex: updatedCurrentIndex,
      timeLeft: updatedTimeLeft,
    );
  }

  void updateTimerTitle(int index, String title) {
    if (index < 0 || index >= state.queue.length) return;
    final newQueue = List<TimerItem>.from(state.queue);
    newQueue[index] = newQueue[index].copyWith(title: title);
    _saveQueue(newQueue);
    state = state.copyWith(queue: newQueue);
  }
}
