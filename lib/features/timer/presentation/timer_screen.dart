import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/time_formatter.dart';
import '../application/timer_controller.dart';
import '../domain/timer_state.dart';
import '../../settings/presentation/settings_screen.dart';
import 'widgets/timer_list_item.dart';

class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(timerControllerProvider);
    final controller = ref.read(timerControllerProvider.notifier);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Section (Active Timer)
            _buildTopSection(context, state, controller),

            // Bottom Section (Next Up Queue)
            Expanded(
              flex: 6,
              child: _buildBottomSection(context, state, controller),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection(
    BuildContext context,
    PomodoroState state,
    TimerController controller,
  ) {
    final currentItem =
        state.queue.isNotEmpty && state.currentIndex < state.queue.length
        ? state.queue[state.currentIndex]
        : null;
    final isPristine =
        currentItem == null || state.timeLeft == currentItem.duration;

    final String primaryBtnLabel = state.isRunning
        ? 'Pause'
        : (isPristine ? 'Start' : 'Resume');
    final IconData primaryBtnIcon = state.isRunning
        ? Icons.pause
        : Icons.play_arrow;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.timer, color: AppTheme.textDark),
                  const SizedBox(width: 8),
                  Text(
                    'Pom',
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(letterSpacing: 1.2),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: AppTheme.textDark),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Huge Timer Display
          Text(
            formatDuration(state.timeLeft),
            style: Theme.of(context).textTheme.displayLarge,
            maxLines: 1,
          ),

          const SizedBox(height: 32),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildActionButton(
                    icon: primaryBtnIcon,
                    label: primaryBtnLabel,
                    onPressed: controller.toggleTimer,
                  ),
                  if (!isPristine || state.isRunning) ...[
                    const SizedBox(width: 8),
                    _buildActionButton(
                      icon: Icons.stop,
                      label: 'Stop',
                      onPressed: controller.reset,
                    ),
                  ],
                ],
              ),
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  controller.addTimer('New Timer', const Duration(minutes: 5));
                },
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: AppTheme.textDark,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      icon: Icon(icon, color: AppTheme.textDark),
      label: Text(
        label,
        style: const TextStyle(
          color: AppTheme.textDark,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppTheme.textDark, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }

  Widget _buildBottomSection(
    BuildContext context,
    PomodoroState state,
    TimerController controller,
  ) {
    // Calculate total time remaining for upcoming timers + current timer
    Duration totalRemaining = state.timeLeft;
    for (int i = state.currentIndex + 1; i < state.queue.length; i++) {
      totalRemaining += state.queue[i].duration;
    }

    String hoursText = '';
    if (totalRemaining.inHours > 0) {
      hoursText =
          "${totalRemaining.inHours} Hour${totalRemaining.inHours == 1 ? '' : 's'} ";
    }
    final int minutes = totalRemaining.inMinutes.remainder(60);
    final String totalTimeStr =
        "$hoursText$minutes Minute${minutes == 1 ? '' : 's'}";

    return Container(
      color: AppTheme.charcoalDark,
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'NEXT UP',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white54,
                    letterSpacing: 2,
                  ),
                ),
                Flexible(
                  child: Text(
                    totalTimeStr,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Reorderable List
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.only(
                bottom: 100,
              ), // padding for scrolling
              itemCount: state.queue.length,
              onReorder: (oldIndex, newIndex) {
                HapticFeedback.mediumImpact();
                controller.reorderTimers(oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final item = state.queue[index];
                return TimerListItem(
                  key: ValueKey(item.id),
                  item: item,
                  isCurrent: index == state.currentIndex,
                  onRemove: () => controller.removeTimer(index),
                  onTitleChanged: (newTitle) {
                    controller.updateTimerTitle(index, newTitle);
                  },
                  onDurationChanged: (newDuration) {
                    controller.updateTimerDuration(index, newDuration);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
