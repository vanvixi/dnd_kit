import 'package:dnd_kit_flutter/dnd_kit_flutter.dart';
import 'package:flutter/material.dart';

/// The `auto-scroll` catalog demo: [DndAutoScroll] scrolls a bounded list while
/// the drag pointer rests in its edge band, so the token can reach an
/// off-screen slot.
class AutoScrollDemo extends StatefulWidget {
  const AutoScrollDemo({super.key});

  @override
  State<AutoScrollDemo> createState() => _AutoScrollDemoState();
}

class _AutoScrollDemoState extends State<AutoScrollDemo> {
  static const int _slotCount = 14;

  late final DndController _controller = DndController();
  int _tokenSlot = 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDragEnd(DndDragEndEvent event) {
    final overId = event.overId;
    if (overId != null && overId.value.startsWith('slot-')) {
      setState(() {
        _tokenSlot = int.parse(overId.value.substring('slot-'.length));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DndScope(
      controller: _controller,
      child: Scaffold(
        appBar: AppBar(title: const Text('Auto-scroll')),
        body: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Text(
                    'Pick up the token and drag it toward the top or bottom '
                    'edge of the bounded list. DndAutoScroll scrolls while the '
                    'pointer stays in the edge band, so the token can reach an '
                    'off-screen slot.',
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.4),
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: DndAutoScroll(
                          child: ListView(
                            padding: const EdgeInsets.all(12),
                            children: <Widget>[
                              for (var slot = 1; slot <= _slotCount; slot++)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _Slot(
                                    slot: slot,
                                    hasToken: slot == _tokenSlot,
                                    onDragEnd: _handleDragEnd,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            DndDragOverlay(
              controller: _controller,
              builder: (context, details) => Material(
                color: Colors.transparent,
                child: Chip(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  label: Text(
                    'Token',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slot extends StatelessWidget {
  const _Slot({
    required this.slot,
    required this.hasToken,
    required this.onDragEnd,
  });

  final int slot;
  final bool hasToken;
  final DndDragEndCallback onDragEnd;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DndDroppable(
      id: DndId('slot-$slot'),
      builder: (context, details, child) {
        return Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 14),
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
      child: Row(
        children: <Widget>[
          Text('Slot $slot', style: TextStyle(color: colorScheme.outline)),
          const Spacer(),
          if (hasToken)
            DndDraggable(
              id: const DndId('auto-scroll-token'),
              onDragEnd: onDragEnd,
              builder: (context, details, child) =>
                  Opacity(opacity: details.isDragging ? 0.4 : 1, child: child),
              child: Chip(
                backgroundColor: colorScheme.primary,
                label: Text(
                  'Drag token',
                  style: TextStyle(color: colorScheme.onPrimary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
