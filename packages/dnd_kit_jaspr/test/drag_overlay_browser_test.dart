@TestOn('browser')
library;

import 'package:dnd_kit_jaspr/dnd_kit_jaspr.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/client_test.dart';
import 'package:universal_web/web.dart' as web;

void main() {
  group('DndDragOverlay browser', () {
    testClient('uses fixed positioning and ignores pointer events by default', (
      tester,
    ) async {
      final controller = DndController();
      addTearDown(controller.dispose);

      tester.pumpComponent(
        DndScope(
          controller: controller,
          child: DndDragOverlay(
            builder: (context, overlay) {
              return div(
                const [Component.text('overlay')],
                attributes: <String, String>{
                  'data-overlay-child': overlay.activeId.value,
                },
              );
            },
          ),
        ),
      );

      controller.beginDrag(
        const DndSensorActivationEvent(
          activeId: DndId('task-1'),
          position: DndPoint(10, 10),
        ),
        activeRect: const DndRect(left: 20, top: 30, width: 40, height: 50),
      );
      controller.startDrag();
      controller.moveDrag(const DndPoint(25, 35));
      await pumpEventQueue();

      final overlay = web.document.querySelector('[data-dnd-overlay="true"]')! as web.HTMLElement;
      expect(overlay.style.position, 'fixed');
      expect(overlay.style.left, '20px');
      expect(overlay.style.top, '30px');
      expect(overlay.style.width, '40px');
      expect(overlay.style.height, '50px');
      expect(overlay.style.pointerEvents, 'none');
      expect(overlay.style.transform, 'translate(15px, 25px)');
      expect(
        web.document.querySelector('[data-overlay-child="task-1"]'),
        isNotNull,
      );
    });

    testClient('keeps the source node still while the overlay follows pointer drag', (
      tester,
    ) async {
      final controller = DndController();
      addTearDown(controller.dispose);

      tester.pumpComponent(
        DndScope(
          controller: controller,
          child: div([
            DndDraggable(
              id: const DndId('task-1'),
              child: section(
                const [Component.text('body')],
                styles: Styles(
                  width: 40.px,
                  height: 50.px,
                ),
              ),
            ),
            DndDragOverlay(
              builder: (context, overlay) {
                return div(
                  const [Component.text('overlay')],
                  attributes: <String, String>{
                    'data-overlay-active-id': overlay.activeId.value,
                  },
                );
              },
            ),
          ]),
        ),
      );

      await tester.dispatchEvent(
        find.tag('section'),
        _pointerEvent('pointerdown', x: 10, y: 10, pointerType: 'mouse', pointerId: 1),
      );
      await tester.dispatchEvent(
        find.tag('section'),
        _pointerEvent('pointermove', x: 40, y: 25, pointerType: 'mouse', pointerId: 1),
      );

      final source = tester.findNode<web.HTMLElement>(find.tag('section'))!;
      final overlay = web.document.querySelector('[data-dnd-overlay="true"]')! as web.HTMLElement;

      expect(source.style.transform, isEmpty);
      expect(overlay.style.transform, isNotEmpty);
      expect(
        web.document.querySelector('[data-overlay-active-id="task-1"]'),
        isNotNull,
      );

      await tester.dispatchEvent(
        find.tag('section'),
        _pointerEvent('pointerup', x: 40, y: 25, pointerType: 'mouse', pointerId: 1),
      );
    });
  });
}

web.PointerEvent _pointerEvent(
  String type, {
  required int x,
  required int y,
  required String pointerType,
  required int pointerId,
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
