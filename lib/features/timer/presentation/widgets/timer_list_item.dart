import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/timer_state.dart';
import '../../../../core/theme/app_theme.dart';

class TimerListItem extends StatefulWidget {
  final TimerItem item;
  final bool isCurrent;
  final VoidCallback onRemove;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<Duration> onDurationChanged;

  const TimerListItem({
    super.key,
    required this.item,
    required this.isCurrent,
    required this.onRemove,
    required this.onTitleChanged,
    required this.onDurationChanged,
  });

  @override
  State<TimerListItem> createState() => _TimerListItemState();
}

class _TimerListItemState extends State<TimerListItem> {
  late TextEditingController _titleController;
  late TextEditingController _durationController;
  final FocusNode _focusNode = FocusNode();
  final FocusNode _durationFocusNode = FocusNode();

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
  }

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    _focusNode.dispose();
    _durationFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.charcoalDark,
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Row(
        children: [
          // Drag handle
          const Icon(Icons.menu, color: Colors.white30, size: 24),
          const SizedBox(width: 16),

          // Title Input
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.charcoalLight,
                borderRadius: BorderRadius.circular(4),
              ),
              child: EditableText(
                controller: _titleController,
                focusNode: _focusNode,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: widget.isCurrent ? Theme.of(context).primaryColor : Colors.white,
                  decoration: widget.item.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                ),
                cursorColor: Theme.of(context).primaryColor,
                backgroundCursorColor: AppTheme.charcoalLight,
                onSubmitted: (_) {
                  _focusNode.unfocus();
                  widget.onTitleChanged(_titleController.text);
                },
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Duration Input
          IntrinsicWidth(
            child: EditableText(
              controller: _durationController,
              focusNode: _durationFocusNode,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
              cursorColor: Theme.of(context).primaryColor,
              backgroundCursorColor: AppTheme.charcoalLight,
              keyboardType: TextInputType.number,
              onSubmitted: (_) {
                _durationFocusNode.unfocus();
                _submitDuration();
              },
            ),
          ),
          const Text(
            ':00',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white54,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),

          const SizedBox(width: 16),

          // Delete Button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onRemove();
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.errorRed, width: 2),
              ),
              child: const Icon(
                Icons.close,
                color: AppTheme.errorRed,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
