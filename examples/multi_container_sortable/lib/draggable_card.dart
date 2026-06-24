import 'package:dnd_kit_flutter/dnd_kit_flutter.dart';
import 'package:flutter/material.dart';

import 'task_card_content.dart';
import 'task_item.dart';

class DraggableCard extends StatefulWidget {
  const DraggableCard({
    super.key,
    required this.task,
  });

  final TaskItem task;

  @override
  State<DraggableCard> createState() => _DraggableCardState();
}

class _DraggableCardState extends State<DraggableCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final taskDndId = DndId(widget.task.id);

    return MouseRegion(
      key: ValueKey('drag:${widget.task.id}'),
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: SortableMultiItem(
        id: taskDndId,
        // Default platform-adaptive activation: immediate with a mouse, but a
        // short hold on touch so a quick swipe scrolls instead of dragging.
        builder: (context, details, child) {
          return AnimatedContainer(
            key: ValueKey('task-drop:${widget.task.id}'),
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              border: Border.all(
                color: details.isOver
                    ? const Color(0xff8b5cf6)
                    : Colors.transparent,
                width: details.isOver ? 2.0 : 0.0,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: details.isDragging ? 0.35 : 1.0,
              child: child,
            ),
          );
        },
        child: AnimatedScale(
          scale: _isHovered ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          child: TaskCardContent(
            task: widget.task,
            isHovered: _isHovered,
          ),
        ),
      ),
    );
  }
}
