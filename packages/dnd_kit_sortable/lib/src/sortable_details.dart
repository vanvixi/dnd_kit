import 'package:dnd_kit_core/dnd_kit_core.dart';

/// Called when a sortable item is dropped over another sortable item.
typedef SortableMoveCallback = void Function(SortableMoveDetails details);

/// Details for an application-owned sortable reorder intent.
final class SortableMoveDetails {
  /// Creates sortable move intent details.
  const SortableMoveDetails({
    required this.activeId,
    required this.overId,
    required this.fromContainerId,
    required this.toContainerId,
    required this.fromIndex,
    required this.toIndex,
    this.event,
  });

  /// The sortable item being moved.
  final DndId activeId;

  /// The sortable item the active item was dropped over.
  final DndId overId;

  /// The source container id, when the move is associated with a container.
  final DndId? fromContainerId;

  /// The destination container id, when the move is associated with a container.
  final DndId? toContainerId;

  /// The active item's index in its source container before the move.
  final int fromIndex;

  /// The target index in the destination container.
  final int toIndex;

  /// The lower-level drag end event that produced this move intent.
  final DndDragEndEvent? event;

  @override
  bool operator ==(Object other) {
    return other is SortableMoveDetails &&
        other.activeId == activeId &&
        other.overId == overId &&
        other.fromContainerId == fromContainerId &&
        other.toContainerId == toContainerId &&
        other.fromIndex == fromIndex &&
        other.toIndex == toIndex &&
        other.event == event;
  }

  @override
  int get hashCode {
    return Object.hash(
      activeId,
      overId,
      fromContainerId,
      toContainerId,
      fromIndex,
      toIndex,
      event,
    );
  }

  @override
  String toString() {
    return 'SortableMoveDetails(activeId: $activeId, overId: $overId, '
        'fromContainerId: $fromContainerId, toContainerId: $toContainerId, '
        'fromIndex: $fromIndex, toIndex: $toIndex, '
        'event: $event)';
  }
}
