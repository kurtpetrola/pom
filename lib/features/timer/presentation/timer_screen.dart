import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/time_formatter.dart';
import '../../settings/presentation/settings_screen.dart';
import '../application/timer_controller.dart';
import '../domain/timer_state.dart';
import 'widgets/timer_list_item.dart';

class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _blinkAnimation = Tween<double>(begin: 1.0, end: 0.3).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  void _updateBlinkState(PomodoroState state) {
    final currentItem = state.queue.isNotEmpty && state.currentIndex < state.queue.length
        ? state.queue[state.currentIndex]
        : null;
    final isPristine = currentItem == null || state.timeLeft == currentItem.duration;
    
    final shouldBlink = !state.isRunning && !isPristine;
    
    if (shouldBlink) {
      if (!_blinkController.isAnimating) {
        _blinkController.repeat(reverse: true);
      }
    } else {
      _blinkController.stop();
      _blinkController.value = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(timerControllerProvider);
    final controller = ref.read(timerControllerProvider.notifier);
    final theme = Theme.of(context);

    // Update blink animation safely outside the build phase.
    // ref.listen fires after rebuild, avoiding use-after-dispose crashes
    // when rapidly navigating between screens.
    ref.listen(timerControllerProvider, (_, next) {
      if (mounted) _updateBlinkState(next);
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
    final theme = Theme.of(context);
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
        ? Icons.pause_rounded
        : Icons.play_arrow_rounded;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          // Header Bar - Minimal
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, color: AppTheme.textDark, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Pom',
                      style: theme.textTheme.labelLarge?.copyWith(
                        letterSpacing: 2,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined, color: AppTheme.textDark, size: 22),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),

          const SizedBox(height: 48),

          // Huge Timer Display - Centered and Bold
          Center(
            child: FadeTransition(
              opacity: _blinkAnimation,
              child: Text(
                formatDuration(state.timeLeft),
                style: theme.textTheme.displayLarge,
                maxLines: 1,
              ),
            ),
          ),

          const SizedBox(height: 48),

          // Action Buttons - Thinner and cleaner
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildActionButton(
                    context: context,
                    icon: primaryBtnIcon,
                    label: primaryBtnLabel,
                    onPressed: controller.toggleTimer,
                    isPrimary: true,
                  ),
                  if (!isPristine || state.isRunning) ...[
                    const SizedBox(width: 12),
                    _buildActionButton(
                      context: context,
                      icon: Icons.stop_rounded,
                      label: 'Stop',
                      onPressed: controller.reset,
                      isPrimary: false,
                    ),
                  ],
                ],
              ),
              // Add Button - Subtler
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  controller.addTimer('New Timer', const Duration(minutes: 5));
                },
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: AppTheme.textDark,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return OutlinedButton.icon(
      onPressed: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      icon: Icon(icon, color: AppTheme.textDark, size: 20),
      label: Text(
        label,
        style: const TextStyle(
          color: AppTheme.textDark,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: AppTheme.textDark.withValues(alpha: isPrimary ? 0.8 : 0.2), 
          width: 1.5,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: isPrimary ? Colors.black.withValues(alpha: 0.02) : Colors.transparent,
      ),
    );
  }

  Widget _buildBottomSection(
    BuildContext context,
    PomodoroState state,
    TimerController controller,
  ) {
    final theme = Theme.of(context);
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
      decoration: const BoxDecoration(
        color: AppTheme.charcoalDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          // Handle-like indicator
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'UP NEXT',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white24,
                    letterSpacing: 3,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Flexible(
                  child: Text(
                    totalTimeStr,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.primaryColor.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
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
              padding: const EdgeInsets.only(bottom: 40),
              itemCount: state.queue.length,
              onReorder: (oldIndex, newIndex) {
                HapticFeedback.mediumImpact();
                controller.reorderTimers(oldIndex, newIndex);
              },
              proxyDecorator: (child, index, animation) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return Material(
                      color: Colors.transparent,
                      child: child,
                    );
                  },
                  child: child,
                );
              },
              itemBuilder: (context, index) {
                final item = state.queue[index];
                return TimerListItem(
                  key: ValueKey(item.id),
                  item: item,
                  isCurrent: index == state.currentIndex,
                  isRunning: state.isRunning,
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
