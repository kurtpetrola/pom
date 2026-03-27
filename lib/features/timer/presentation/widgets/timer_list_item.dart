import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/timer_state.dart';

class TimerListItem extends StatefulWidget {
  final TimerItem item;
  final bool isCurrent;
  final bool isRunning;
  final VoidCallback onRemove;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<Duration> onDurationChanged;

  const TimerListItem({
    super.key,
    required this.item,
    required this.isCurrent,
    required this.isRunning,
    required this.onRemove,
    required this.onTitleChanged,
    required this.onDurationChanged,
  });

  @override
  State<TimerListItem> createState() => _TimerListItemState();
}

class _TimerListItemState extends State<TimerListItem> with SingleTickerProviderStateMixin {
  late TextEditingController _titleController;
  late TextEditingController _durationController;
  final FocusNode _focusNode = FocusNode();
  final FocusNode _durationFocusNode = FocusNode();
  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item.title);
    _durationController = TextEditingController(
      text: widget.item.duration.inMinutes.toString(),
    );

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _titleController.text != widget.item.title) {
        widget.onTitleChanged(_titleController.text);
      }
    });

    _durationFocusNode.addListener(() {
      if (!_durationFocusNode.hasFocus) {
        _submitDuration();
      }
    });

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _blinkAnimation = Tween<double>(begin: 1.0, end: 0.3).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );

    _updateBlinkState();
  }

  void _updateBlinkState() {
    final shouldBlink = widget.isCurrent && !widget.isRunning && !widget.item.isCompleted &&
        widget.item.duration != Duration.zero; // Simple check for "started but paused" is usually done via timeLeft != duration, but we don't have timeLeft here.
    // Wait, we need to know if the timer is paused. 
    // Actually, in the list item, if it's CURRENT and NOT RUNNING, it's paused.
    if (shouldBlink) {
      _blinkController.repeat(reverse: true);
    } else {
      _blinkController.stop();
      _blinkController.value = 0; // 0 for the animation means 1.0 opacity (value=0 -> begin=1.0)
    }
  }

  void _submitDuration() {
    final parsed = int.tryParse(_durationController.text);
    if (parsed != null && parsed > 0) {
      widget.onDurationChanged(Duration(minutes: parsed));
    } else {
      _durationController.text = widget.item.duration.inMinutes.toString();
    }
  }

  @override
  void didUpdateWidget(covariant TimerListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.title != widget.item.title &&
        _titleController.text != widget.item.title) {
      _titleController.text = widget.item.title;
    }
    if (oldWidget.item.duration != widget.item.duration &&
        _durationController.text != widget.item.duration.inMinutes.toString()) {
      _durationController.text = widget.item.duration.inMinutes.toString();
    }
    if (oldWidget.isRunning != widget.isRunning || oldWidget.isCurrent != widget.isCurrent) {
      _updateBlinkState();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    _focusNode.dispose();
    _durationFocusNode.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Subtler Drag Handle
          const Icon(Icons.drag_indicator_rounded, color: Colors.white10, size: 20),
          const SizedBox(width: 12),

          // Title Input - No background for a cleaner look
          Expanded(
            child: FadeTransition(
              opacity: _blinkAnimation,
              child: EditableText(
                controller: _titleController,
                focusNode: _focusNode,
                style: theme.textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w500,
                  color: widget.isCurrent 
                    ? theme.primaryColor 
                    : AppTheme.textLight.withValues(alpha: 0.9),
                  decoration: widget.item.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                ),
                cursorColor: theme.primaryColor,
                backgroundCursorColor: AppTheme.charcoalLight,
                onSubmitted: (_) {
                  _focusNode.unfocus();
                  widget.onTitleChanged(_titleController.text);
                },
              ),
            ),
          ),

          if (widget.isCurrent && widget.isRunning) ...[
            const SizedBox(width: 8),
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor.withValues(alpha: 0.8)),
              ),
            ),
          ],

          const SizedBox(width: 12),

          // Duration Input
          IntrinsicWidth(
            child: FadeTransition(
              opacity: _blinkAnimation,
              child: EditableText(
                controller: _durationController,
                focusNode: _durationFocusNode,
                style: theme.textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textLight.withValues(alpha: 0.9),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
                cursorColor: theme.primaryColor,
                backgroundCursorColor: AppTheme.charcoalLight,
                keyboardType: TextInputType.number,
                onSubmitted: (_) {
                  _durationFocusNode.unfocus();
                  _submitDuration();
                },
              ),
            ),
          ),
          Text(
            ':00',
            style: theme.textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.textLight.withValues(alpha: 0.2),
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),

          const SizedBox(width: 16),

          // Delete Button - Muted style
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onRemove();
            },
            child: Icon(
              Icons.close_rounded,
              color: AppTheme.textLight.withValues(alpha: 0.1),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
