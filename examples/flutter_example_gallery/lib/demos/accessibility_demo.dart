import 'package:dnd_kit_flutter/dnd_kit_flutter.dart';
import 'package:flutter/material.dart';

/// The `accessibility` catalog demo: every draggable is operable from the
/// keyboard, and the adapter emits semantics announcements as the drag
/// progresses — accessibility is built in, not bolted on.
class AccessibilityDemo extends StatefulWidget {
  const AccessibilityDemo({super.key});

  @override
  State<AccessibilityDemo> createState() => _AccessibilityDemoState();
}

const _laneIds = <String>['todo', 'doing', 'done'];
const _laneLabels = <String, String>{
  'todo': 'To do',
  'doing': 'Doing',
  'done': 'Done',
};

class _AccessibilityDemoState extends State<AccessibilityDemo> {
  late final DndController _controller = DndController();
  String _lane = 'todo';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDragEnd(DndDragEndEvent event) {
    final overId = event.overId;
    if (overId != null && _laneIds.contains(overId.value)) {
      setState(() => _lane = overId.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DndScope(
      controller: _controller,
      child: Scaffold(
        appBar: AppBar(title: const Text('Accessibility')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _Instructions(),
              const SizedBox(height: 16),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    for (final id in _laneIds) ...<Widget>[
                      Expanded(
                        child: _Lane(
                          id: id,
                          hasCard: id == _lane,
                          onDragEnd: _handleDragEnd,
                        ),
                      ),
                      if (id != _laneIds.last) const SizedBox(width: 12),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Instructions extends StatelessWidget {
  const _Instructions();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[
          Text(
            'Operate the card without a mouse:',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 6),
          Text('• Tab to focus the card, then Space or Enter to pick it up.'),
          Text('• Arrow keys move it between lanes; Space drops it.'),
          Text('• Escape cancels and returns it. A live region announces each '
              'step.'),
        ],
      ),
    );
  }
}

class _Lane extends StatelessWidget {
  const _Lane({
    required this.id,
    required this.hasCard,
    required this.onDragEnd,
  });

  final String id;
  final bool hasCard;
  final DndDragEndCallback onDragEnd;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DndDroppable(
      id: DndId(id),
      builder: (context, details, child) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: details.isOver
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.3),
              width: details.isOver ? 2 : 1,
            ),
            color: details.isOver
                ? colorScheme.primaryContainer.withValues(alpha: 0.25)
                : colorScheme.surface,
          ),
          child: child,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            _laneLabels[id]!,
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          if (hasCard)
            DndDraggable(
              id: const DndId('a11y-card'),
              label: 'Release task',
              hint: 'Drag or use the keyboard to move between lanes',
              onDragEnd: onDragEnd,
              builder: (context, details, child) =>
                  Opacity(opacity: details.isDragging ? 0.4 : 1, child: child),
              child: Card(
                color: colorScheme.secondaryContainer,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  child: Text('Release task'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
