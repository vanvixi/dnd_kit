import 'package:flutter/material.dart';

import 'task_item.dart';

class TaskCardContent extends StatelessWidget {
  const TaskCardContent({
    super.key,
    required this.task,
    this.isDraggingOverlay = false,
    this.isHovered = false,
  });

  final TaskItem task;
  final bool isDraggingOverlay;
  final bool isHovered;

  @override
  Widget build(BuildContext context) {
    final themeColor = task.color;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: isDraggingOverlay ? 0.12 : 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHovered || isDraggingOverlay
              ? themeColor.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.08),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(alpha: isDraggingOverlay ? 0.4 : 0.15),
            blurRadius: isDraggingOverlay ? 16 : 8,
            offset: Offset(0, isDraggingOverlay ? 8 : 4),
          ),
          if (isHovered || isDraggingOverlay)
            BoxShadow(
              color: themeColor.withValues(alpha: 0.08),
              blurRadius: 12,
              spreadRadius: 1,
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row for Priority & Accent Color Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _priorityColor(task.priority).withValues(alpha: 0.12),
                  border: Border.all(
                    color: _priorityColor(task.priority).withValues(alpha: 0.4),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  task.priority,
                  style: TextStyle(
                    color: _priorityColor(task.priority),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: themeColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: themeColor.withValues(alpha: 0.5),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            task.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),

          // Description
          Text(
            task.description,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),

          // Owner Avatar & Info Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_circle_outlined,
                    size: 16,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    task.owner,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.drag_indicator,
                size: 16,
                color: Colors.white.withValues(alpha: 0.35),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'High':
        return const Color(0xffef4444);
      case 'Medium':
        return const Color(0xfff59e0b);
      case 'Low':
        return const Color(0xff10b981);
      default:
        return const Color(0xff9ca3af);
    }
  }
}
