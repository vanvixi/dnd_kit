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
  });
}

// A 200x100 scroll viewport over 600px of content. The draggable handle sits at
// the top; the drop target is below the fold (content top 250) and only enters
// view after auto-scroll runs.
Component _autoScrollHarness({bool enabled = true}) {
  return DndAutoScroll(
    id: 'scroll-view',
    enabled: enabled,
    styles: Styles(
      position: Position.fixed(left: 0.px, top: 0.px),
      width: 200.px,
      height: 100.px,
      overflow: Overflow.only(y: Overflow.scroll),
    ),
    child: div(
      styles: Styles(position: Position.relative(), height: 600.px, width: 180.px),
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
          styles: Styles(position: Position.absolute(left: 0.px, top: 250.px)),
          [
            DndDroppable(
              id: const DndId('drop-zone'),
              child: article(
                styles: Styles(width: 180.px, height: 350.px),
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
