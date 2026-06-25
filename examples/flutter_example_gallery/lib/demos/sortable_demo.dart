import 'package:dnd_kit_flutter/dnd_kit_flutter.dart';
import 'package:flutter/material.dart';

/// The `sortable` catalog demo: SortableScope + SortableItem turn a list into a
/// reorderable one. dnd_kit reports from/to indices; the list owns its order.
class SortableDemo extends StatefulWidget {
  const SortableDemo({super.key});

  @override
  State<SortableDemo> createState() => _SortableDemoState();
}

class _SortableDemoState extends State<SortableDemo> {
  final List<_Track> _tracks = <_Track>[
    const _Track('track-1', 'Write the launch brief'),
    const _Track('track-2', 'Design the board UI'),
    const _Track('track-3', 'Wire the drag engine'),
    const _Track('track-4', 'Add keyboard support'),
    const _Track('track-5', 'Ship the release'),
  ];

  void _handleMove(SortableMoveDetails details) {
    setState(() {
      final track = _tracks.removeAt(details.fromIndex);
      _tracks.insert(details.toIndex, track);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sortable list')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Drag a row to reorder it, or focus one and use the keyboard. '
              'dnd_kit reports the move as from/to indices; the list owns its '
              'order.',
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SortableScope(
                strategy: SortableStrategies.verticalList,
                itemIds: <DndId>[for (final track in _tracks) DndId(track.id)],
                onMove: _handleMove,
                child: ListView(
                  children: <Widget>[
                    for (final track in _tracks)
                      Padding(
                        key: ValueKey<String>(track.id),
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SortableItem(
                          id: DndId(track.id),
                          builder: (context, details, child) => Opacity(
                            opacity: details.isDragging ? 0.4 : 1,
                            child: child,
                          ),
                          child: _TrackRow(label: track.label),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Track {
  const _Track(this.id, this.label);

  final String id;
  final String label;
}

class _TrackRow extends StatelessWidget {
  const _TrackRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.drag_indicator, color: colorScheme.outline),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}
