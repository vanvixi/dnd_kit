import 'package:dnd_kit_jaspr/dnd_kit_jaspr.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr_test/jaspr_test.dart';

const _a = DndId('a');
const _b = DndId('b');
const _c = DndId('c');

// Three items stacked vertically with 10px gaps; centers at y = 10, 40, 70.
final _rects = <DndId, DndRect>{
  _a: const DndRect(left: 0, top: 0, width: 20, height: 20),
  _b: const DndRect(left: 0, top: 30, width: 20, height: 20),
  _c: const DndRect(left: 0, top: 60, width: 20, height: 20),
};

DndDragEndEvent _endEvent({
  required DndId active,
  required DndId? over,
  DndPoint from = DndPoint.zero,
  DndPoint to = DndPoint.zero,
}) {
  return DndDragEndEvent(
    session: DndDragSession(
      activeId: active,
      initialPointer: from,
      currentPointer: to,
    ),
    overId: over,
  );
}

void main() {
  group('SortableScopeData.moveDetailsFor', () {
    final scope = SortableScopeData(itemIds: const [_a, _b, _c]);

    test('returns null when there is no drop-over target', () {
      expect(scope.moveDetailsFor(_endEvent(active: _a, over: null)), isNull);
    });

    test('returns null when dropped over itself', () {
      expect(scope.moveDetailsFor(_endEvent(active: _a, over: _a)), isNull);
    });

    test('returns null when the active item is outside the scope', () {
      expect(
        scope.moveDetailsFor(_endEvent(active: const DndId('x'), over: _b)),
        isNull,
      );
    });

    test('falls back to the drop-over index without measured rects', () {
      final details = scope.moveDetailsFor(_endEvent(active: _a, over: _c));

      expect(details, isNotNull);
      expect(details!.activeId, _a);
      expect(details.overId, _c);
      expect(details.fromIndex, 0);
      expect(details.toIndex, 2);
    });

    test('computes a downward vertical move from measured geometry', () {
      // Drag a (center y=10) down so its translated center (y=75) passes c (70).
      final details = scope.moveDetailsFor(
        _endEvent(
          active: _a,
          over: _c,
          from: const DndPoint(10, 10),
          to: const DndPoint(10, 75),
        ),
        itemRects: _rects,
        activeRect: _rects[_a],
      );

      expect(details, isNotNull);
      expect(details!.fromIndex, 0);
      expect(details.toIndex, 2);
    });

    test('computes an upward vertical move from measured geometry', () {
      // Drag c (center y=70) up so its translated center (y=5) passes a (10).
      final details = SortableScopeData(itemIds: const [_a, _b, _c]).moveDetailsFor(
        _endEvent(
          active: _c,
          over: _a,
          from: const DndPoint(10, 70),
          to: const DndPoint(10, 5),
        ),
        itemRects: _rects,
        activeRect: _rects[_c],
      );

      expect(details, isNotNull);
      expect(details!.fromIndex, 2);
      expect(details.toIndex, 0);
    });

    test('carries the configured container id on both ends', () {
      final contained = SortableScopeData(
        itemIds: const [_a, _b, _c],
        containerId: const DndId('list'),
      );

      final details = contained.moveDetailsFor(_endEvent(active: _a, over: _b));

      expect(details!.fromContainerId, const DndId('list'));
      expect(details.toContainerId, const DndId('list'));
    });

    test('indexOf reports item position and -1 when absent', () {
      expect(scope.indexOf(_b), 1);
      expect(scope.indexOf(const DndId('missing')), -1);
    });
  });

  group('SortableScope provision', () {
    testComponents('exposes scope data to descendants via SortableScope.of', (tester) async {
      SortableScopeData? seen;

      tester.pumpComponent(
        SortableScope(
          itemIds: const [_a, _b],
          child: Builder(builder: (context) {
            seen = SortableScope.of(context);
            return const RawText('child');
          }),
        ),
      );

      expect(seen, isNotNull);
      expect(seen!.itemIds, const [_a, _b]);
      expect(seen!.indexOf(_b), 1);
    });

    testComponents('maybeOf returns null outside a SortableScope', (tester) async {
      SortableScopeData? seen = SortableScopeData(itemIds: const [_a]);

      tester.pumpComponent(
        Builder(builder: (context) {
          seen = SortableScope.maybeOf(context);
          return const RawText('child');
        }),
      );

      expect(seen, isNull);
    });
  });
}
