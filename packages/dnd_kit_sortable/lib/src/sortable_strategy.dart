import 'package:dnd_kit_core/dnd_kit_core.dart';
import 'package:meta/meta.dart';

import 'sortable_details.dart';

/// Computes sortable move intent for a drag end.
typedef SortableStrategy = SortableMoveDetails? Function(SortableStrategyInput input);

/// Input passed to a [SortableStrategy].
@immutable
final class SortableStrategyInput {
  /// Creates sortable strategy input.
  SortableStrategyInput({
    required this.activeId,
    required this.overId,
    required Iterable<DndId> itemIds,
    required Map<DndId, DndRect> itemRects,
    required this.oldIndex,
    required this.containerId,
    required this.event,
    this.activeRect,
    this.activeTranslatedRect,
  })  : itemIds = List<DndId>.unmodifiable(itemIds),
        itemRects = Map<DndId, DndRect>.unmodifiable(itemRects);

  /// The sortable item being moved.
  final DndId activeId;

  /// The sortable item currently under the active drag, when one exists.
  final DndId? overId;

  /// The application-owned item order.
  final List<DndId> itemIds;

  /// Measured item rectangles keyed by sortable item id.
  final Map<DndId, DndRect> itemRects;

  /// The active item's index before the move.
  final int oldIndex;

  /// Optional sortable container id for future multi-container APIs.
  final DndId? containerId;

  /// The lower-level drag end event that produced this strategy input.
  final DndDragEndEvent event;

  /// The measured active rectangle before translation, when known.
  final DndRect? activeRect;

  /// The measured active rectangle after drag translation, when known.
  final DndRect? activeTranslatedRect;

  /// Builds the previous drop-over move intent for fallback strategies.
  SortableMoveDetails? fallbackMoveDetails({int? newIndex}) {
    final overId = this.overId;
    if (overId == null || overId == activeId || oldIndex < 0) {
      return null;
    }

    final fallbackIndex = itemIds.indexOf(overId);
    if (fallbackIndex < 0) {
      return null;
    }

    return SortableMoveDetails(
      activeId: activeId,
      overId: overId,
      oldIndex: oldIndex,
      newIndex: newIndex ?? fallbackIndex,
      containerId: containerId,
      event: event,
    );
  }
}

/// Built-in sortable strategies.
abstract final class SortableStrategies {
  /// Computes same-container vertical list movement from measured item centers.
  static SortableMoveDetails? verticalList(SortableStrategyInput input) {
    final fallback = input.fallbackMoveDetails();
    if (fallback == null) {
      return null;
    }

    final activeTranslatedRect = input.activeTranslatedRect;
    if (activeTranslatedRect == null) {
      return fallback;
    }

    final measuredItems = <_MeasuredSortableItem>[];
    for (final id in input.itemIds) {
      if (id == input.activeId) {
        continue;
      }

      final rect = input.itemRects[id];
      if (rect == null) {
        return fallback;
      }

      measuredItems.add(_MeasuredSortableItem(id: id, rect: rect));
    }

    if (!_hasVerticalSeparation(
      measuredItems,
      activeCenterY: activeTranslatedRect.center.y,
    )) {
      return fallback;
    }

    measuredItems.sort(_compareVerticalItems);
    final newIndex = _verticalInsertionIndex(
      activeCenterY: activeTranslatedRect.center.y,
      measuredItems: measuredItems,
    );

    if (newIndex == input.oldIndex) {
      return null;
    }

    return input.fallbackMoveDetails(newIndex: newIndex);
  }

  /// Computes same-container horizontal list movement from measured item centers.
  static SortableMoveDetails? horizontalList(SortableStrategyInput input) {
    final fallback = input.fallbackMoveDetails();
    if (fallback == null) {
      return null;
    }

    final activeTranslatedRect = input.activeTranslatedRect;
    if (activeTranslatedRect == null) {
      return fallback;
    }

    final measuredItems = <_MeasuredSortableItem>[];
    for (final id in input.itemIds) {
      if (id == input.activeId) {
        continue;
      }

      final rect = input.itemRects[id];
      if (rect == null) {
        return fallback;
      }

      measuredItems.add(_MeasuredSortableItem(id: id, rect: rect));
    }

    if (!_hasHorizontalSeparation(
      measuredItems,
      activeCenterX: activeTranslatedRect.center.x,
    )) {
      return fallback;
    }

    measuredItems.sort(_compareHorizontalItems);
    final newIndex = _horizontalInsertionIndex(
      activeCenterX: activeTranslatedRect.center.x,
      measuredItems: measuredItems,
    );

    if (newIndex == input.oldIndex) {
      return null;
    }

    return input.fallbackMoveDetails(newIndex: newIndex);
  }

  /// Computes same-container grid movement from measured item centers.
  static SortableMoveDetails? grid(SortableStrategyInput input) {
    final fallback = input.fallbackMoveDetails();
    if (fallback == null) {
      return null;
    }

    final activeTranslatedRect = input.activeTranslatedRect;
    if (activeTranslatedRect == null) {
      return fallback;
    }

    final measuredItems = <_MeasuredSortableItem>[];
    for (final id in input.itemIds) {
      if (id == input.activeId) {
        continue;
      }

      final rect = input.itemRects[id];
      if (rect == null) {
        return fallback;
      }

      measuredItems.add(_MeasuredSortableItem(id: id, rect: rect));
    }

    final activeCenter = activeTranslatedRect.center;
    if (!_hasVerticalSeparation(measuredItems, activeCenterY: activeCenter.y) ||
        !_hasHorizontalSeparation(measuredItems, activeCenterX: activeCenter.x)) {
      return fallback;
    }

    measuredItems.sort(_compareGridItems);
    final newIndex = _gridInsertionIndex(
      activeCenter: activeCenter,
      measuredItems: measuredItems,
    );

    if (newIndex == input.oldIndex) {
      return null;
    }

    return input.fallbackMoveDetails(newIndex: newIndex);
  }
}

final class _MeasuredSortableItem {
  const _MeasuredSortableItem({
    required this.id,
    required this.rect,
  });

  final DndId id;
  final DndRect rect;
}

bool _hasVerticalSeparation(
  List<_MeasuredSortableItem> measuredItems, {
  required double activeCenterY,
}) {
  return measuredItems.any((item) => item.rect.center.y != activeCenterY);
}

bool _hasHorizontalSeparation(
  List<_MeasuredSortableItem> measuredItems, {
  required double activeCenterX,
}) {
  return measuredItems.any((item) => item.rect.center.x != activeCenterX);
}

int _verticalInsertionIndex({
  required double activeCenterY,
  required List<_MeasuredSortableItem> measuredItems,
}) {
  var index = 0;
  for (final item in measuredItems) {
    if (activeCenterY > item.rect.center.y) {
      index += 1;
      continue;
    }

    break;
  }

  return index;
}

int _horizontalInsertionIndex({
  required double activeCenterX,
  required List<_MeasuredSortableItem> measuredItems,
}) {
  var index = 0;
  for (final item in measuredItems) {
    if (activeCenterX > item.rect.center.x) {
      index += 1;
      continue;
    }

    break;
  }

  return index;
}

int _gridInsertionIndex({
  required DndPoint activeCenter,
  required List<_MeasuredSortableItem> measuredItems,
}) {
  var index = 0;
  for (final item in measuredItems) {
    final itemCenter = item.rect.center;
    final rowComparison = activeCenter.y.compareTo(itemCenter.y);
    if (rowComparison > 0 || rowComparison == 0 && activeCenter.x > itemCenter.x) {
      index += 1;
      continue;
    }

    break;
  }

  return index;
}

int _compareVerticalItems(_MeasuredSortableItem a, _MeasuredSortableItem b) {
  final centerComparison = a.rect.center.y.compareTo(b.rect.center.y);
  if (centerComparison != 0) {
    return centerComparison;
  }

  final topComparison = a.rect.top.compareTo(b.rect.top);
  if (topComparison != 0) {
    return topComparison;
  }

  return a.id.value.compareTo(b.id.value);
}

int _compareHorizontalItems(_MeasuredSortableItem a, _MeasuredSortableItem b) {
  final centerComparison = a.rect.center.x.compareTo(b.rect.center.x);
  if (centerComparison != 0) {
    return centerComparison;
  }

  final leftComparison = a.rect.left.compareTo(b.rect.left);
  if (leftComparison != 0) {
    return leftComparison;
  }

  return a.id.value.compareTo(b.id.value);
}

int _compareGridItems(_MeasuredSortableItem a, _MeasuredSortableItem b) {
  final rowComparison = a.rect.center.y.compareTo(b.rect.center.y);
  if (rowComparison != 0) {
    return rowComparison;
  }

  final columnComparison = a.rect.center.x.compareTo(b.rect.center.x);
  if (columnComparison != 0) {
    return columnComparison;
  }

  final topComparison = a.rect.top.compareTo(b.rect.top);
  if (topComparison != 0) {
    return topComparison;
  }

  final leftComparison = a.rect.left.compareTo(b.rect.left);
  if (leftComparison != 0) {
    return leftComparison;
  }

  return a.id.value.compareTo(b.id.value);
}
