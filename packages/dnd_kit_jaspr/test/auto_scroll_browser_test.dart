@TestOn('browser')
library;

import 'package:dnd_kit_jaspr/dnd_kit_jaspr.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/client_test.dart';
import 'package:universal_web/web.dart' as web;

void main() {
  group('DndAutoScroll browser', () {
    testClient('scrolls the viewport while a drag rests in the trailing edge band', (tester) async {
      final controller = DndController();
      addTearDown(controller.dispose);

      tester.pumpComponent(
        DndScope(
          controller: controller,
          child: _autoScrollHarness(),
        ),
      );

      final viewport = _viewport();
      expect(viewport.scrollTop, 0);

      // Pick up from the handle, then hold the pointer in the bottom edge band.
      await tester.dispatchEvent(
        find.tag('button'),
        _pointerEvent('pointerdown', x: 30, y: 10, pointerId: 1),
      );
      await tester.dispatchEvent(
        find.tag('button'),
        _pointerEvent('pointermove', x: 30, y: 95, pointerId: 1),
      );

      // Auto-scroll is paced by a frame-interval timer, so let real time pass.
      await _waitUntil(() => viewport.scrollTop > 0);
      expect(viewport.scrollTop, greaterThan(0));

      await tester.dispatchEvent(
        find.tag('button'),
        _pointerEvent('pointerup', x: 30, y: 95, pointerId: 1),
      );
      expect(controller.state, const DndIdle());
    });

    testClient('scrolls horizontally while a drag rests in the trailing edge band', (tester) async {
      final controller = DndController();
      addTearDown(controller.dispose);

      tester.pumpComponent(
        DndScope(
          controller: controller,
          child: _autoScrollHarness(axis: DndScrollAxis.horizontal),
        ),
      );

      final viewport = _viewport();
      expect(viewport.scrollLeft, 0);

      await tester.dispatchEvent(
        find.tag('button'),
        _pointerEvent('pointerdown', x: 10, y: 30, pointerId: 4),
      );
      await tester.dispatchEvent(
        find.tag('button'),
        _pointerEvent('pointermove', x: 195, y: 30, pointerId: 4),
      );

      await _waitUntil(() => viewport.scrollLeft > 0);
      expect(viewport.scrollLeft, greaterThan(0));

      await tester.dispatchEvent(
        find.tag('button'),
        _pointerEvent('pointerup', x: 195, y: 30, pointerId: 4),
      );
      expect(controller.state, const DndIdle());
    });

    testClient('resolves collision against a target scrolled into view', (tester) async {
      final controller = DndController();
      addTearDown(controller.dispose);

      tester.pumpComponent(
        DndScope(
          controller: controller,
          child: _autoScrollHarness(),
        ),
      );

      // The drop target sits below the fold, so nothing collides before scroll.
      await tester.dispatchEvent(
        find.tag('button'),
        _pointerEvent('pointerdown', x: 30, y: 10, pointerId: 2),
      );
      await tester.dispatchEvent(
        find.tag('button'),
        _pointerEvent('pointermove', x: 30, y: 95, pointerId: 2),
      );
      expect(controller.overId, isNull);

      // As the viewport scrolls the target up into view, collision resolves
      // against the post-scroll coordinates without any further pointer move.
      await _waitUntil(() => controller.overId == const DndId('drop-zone'));
      expect(controller.overId, const DndId('drop-zone'));

      await tester.dispatchEvent(
        find.tag('button'),
        _pointerEvent('pointerup', x: 30, y: 95, pointerId: 2),
      );
      expect(controller.state, const DndIdle());
    });

    testClient('resolves horizontal collision against a target scrolled into view', (tester) async {
      final controller = DndController();
      addTearDown(controller.dispose);

      tester.pumpComponent(
        DndScope(
          controller: controller,
          child: _autoScrollHarness(axis: DndScrollAxis.horizontal),
        ),
      );

      await tester.dispatchEvent(
        find.tag('button'),
        _pointerEvent('pointerdown', x: 10, y: 30, pointerId: 5),
      );
      await tester.dispatchEvent(
        find.tag('button'),
        _pointerEvent('pointermove', x: 195, y: 30, pointerId: 5),
      );
      expect(controller.overId, isNull);

      await _waitUntil(() => controller.overId == const DndId('drop-zone'));
      expect(controller.overId, const DndId('drop-zone'));

      await tester.dispatchEvent(
        find.tag('button'),
        _pointerEvent('pointerup', x: 195, y: 30, pointerId: 5),
      );
      expect(controller.state, const DndIdle());
    });

    testClient('does not scroll while disabled', (tester) async {
      final controller = DndController();
      addTearDown(controller.dispose);

      tester.pumpComponent(
        DndScope(
          controller: controller,
          child: _autoScrollHarness(enabled: false),
        ),
      );

      final viewport = _viewport();
      await tester.dispatchEvent(
        find.tag('button'),
        _pointerEvent('pointerdown', x: 30, y: 10, pointerId: 3),
      );
      await tester.dispatchEvent(
        find.tag('button'),
        _pointerEvent('pointermove', x: 30, y: 95, pointerId: 3),
      );

      await _settle();
      expect(viewport.scrollTop, 0);

      await tester.dispatchEvent(
        find.tag('button'),
        _pointerEvent('pointerup', x: 30, y: 95, pointerId: 3),
      );
      expect(controller.state, const DndIdle());
    });

    testClient('does not exceed horizontal scroll extents', (tester) async {
      final controller = DndController();
      addTearDown(controller.dispose);

      tester.pumpComponent(
        DndScope(
          controller: controller,
          child: _autoScrollHarness(axis: DndScrollAxis.horizontal),
        ),
      );

      final viewport = _viewport();
      await tester.dispatchEvent(
        find.tag('button'),
        _pointerEvent('pointerdown', x: 10, y: 30, pointerId: 6),
      );
      await tester.dispatchEvent(
        find.tag('button'),
        _pointerEvent('pointermove', x: 195, y: 30, pointerId: 6),
      );

      await _waitUntil(() => viewport.scrollLeft >= _maxScrollLeft(viewport));
      expect(viewport.scrollLeft, _maxScrollLeft(viewport));

      await _settle();
      expect(viewport.scrollLeft, _maxScrollLeft(viewport));

      await tester.dispatchEvent(
        find.tag('button'),
        _pointerEvent('pointerup', x: 195, y: 30, pointerId: 6),
      );
      expect(controller.state, const DndIdle());
    });
  });
}

// A 200x100 scroll viewport over 600px of content. The draggable handle sits at
// the top-left; the drop target is positioned beyond the initial fold on the
// selected axis and only enters view after auto-scroll runs.
Component _autoScrollHarness({
  bool enabled = true,
  DndScrollAxis axis = DndScrollAxis.vertical,
}) {
  return DndAutoScroll(
    id: 'scroll-view',
    enabled: enabled,
    axis: axis,
    styles: Styles(
      position: Position.fixed(left: 0.px, top: 0.px),
      width: 200.px,
      height: 100.px,
      overflow: axis == DndScrollAxis.horizontal
          ? Overflow.only(x: Overflow.scroll)
          : Overflow.only(y: Overflow.scroll),
    ),
    child: div(
      styles: Styles(
        position: Position.relative(),
        height: axis == DndScrollAxis.horizontal ? 80.px : 600.px,
        width: axis == DndScrollAxis.horizontal ? 600.px : 180.px,
      ),
      [
        div(
          styles: Styles(position: Position.absolute(left: 0.px, top: 0.px)),
          [
            DndDraggable(
              id: const DndId('task-1'),
              child: button(
                styles: Styles(width: 60.px, height: 20.px),
                const [Component.text('handle')],
              ),
            ),
          ],
        ),
        div(
          styles: Styles(
            position: Position.absolute(
              left: axis == DndScrollAxis.horizontal ? 320.px : 0.px,
              top: axis == DndScrollAxis.horizontal ? 0.px : 250.px,
            ),
          ),
          [
            DndDroppable(
              id: const DndId('drop-zone'),
              child: article(
                styles: Styles(
                  width: axis == DndScrollAxis.horizontal ? 180.px : 180.px,
                  height: axis == DndScrollAxis.horizontal ? 80.px : 350.px,
                ),
                const [Component.text('drop zone')],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

web.HTMLElement _viewport() {
  return web.document.getElementById('scroll-view')! as web.HTMLElement;
}

double _maxScrollLeft(web.HTMLElement viewport) {
  return (viewport.scrollWidth - viewport.clientWidth).toDouble();
}

Future<void> _waitUntil(bool Function() condition, {int attempts = 80}) async {
  for (var i = 0; i < attempts; i++) {
    if (condition()) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 16));
  }
}

Future<void> _settle() async {
  await Future<void>.delayed(const Duration(milliseconds: 200));
}

web.PointerEvent _pointerEvent(
  String type, {
  required int x,
  required int y,
  required int pointerId,
  String pointerType = 'mouse',
}) {
  return web.PointerEvent(
    type,
    web.PointerEventInit(
      bubbles: true,
      cancelable: true,
      composed: true,
      clientX: x,
      clientY: y,
      pointerType: pointerType,
      pointerId: pointerId,
    ),
  );
}
