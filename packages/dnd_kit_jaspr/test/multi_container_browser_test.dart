@TestOn('browser')
library;

import 'package:dnd_kit_jaspr/dnd_kit_jaspr.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/client_test.dart';
import 'package:universal_web/web.dart' as web;

void main() {
  group('SortableMultiContainer browser', () {
    testClient(
      'computes cross-container move intent from a Jaspr drag flow',
      (tester) async {
        final containers = <SortableContainer>[
          SortableContainer(
            id: const DndId('todo'),
            itemIds: const <DndId>[DndId('task-1')],
          ),
          SortableContainer(
            id: const DndId('done'),
            itemIds: const <DndId>[],
          ),
        ];
        SortableMoveDetails? move;

        tester.pumpComponent(
          SortableMultiScope(
            containers: containers,
            onMove: (moveDetails) {
              move = moveDetails;
            },
            child: div([
              div(
                styles: Styles(position: Position.fixed(left: 0.px, top: 0.px)),
                [
                  SortableMultiContainerArea(
                    id: const DndId('todo'),
                    itemIds: const <DndId>[DndId('task-1')],
                    child: SortableMultiItem(
                      id: const DndId('task-1'),
                      child: button([Component.text('task')]),
                    ),
                  ),
                ],
              ),
              div(
                styles: Styles(position: Position.fixed(left: 240.px, top: 0.px)),
                [
                  SortableMultiContainerArea(
                    id: const DndId('done'),
                    itemIds: const <DndId>[],
                    child: article(
                      styles: Styles(width: 120.px, height: 120.px),
                      const [Component.text('done')],
                    ),
                  ),
                ],
              ),
            ]),
          ),
        );

        await tester.dispatchEvent(
          find.tag('button'),
          _pointerEvent('pointerdown', x: 20, y: 20, pointerId: 1),
        );
        await tester.dispatchEvent(
          find.tag('article'),
          _pointerEvent('pointermove', x: 280, y: 20, pointerId: 1),
        );

        await tester.dispatchEvent(
          find.tag('article'),
          _pointerEvent('pointerup', x: 280, y: 20, pointerId: 1),
        );

        expect(move, isNotNull);
        expect(move!.activeId, const DndId('task-1'));
        expect(move!.overId, const DndId('done'));
        expect(move!.fromContainerId, const DndId('todo'));
        expect(move!.toContainerId, const DndId('done'));
        expect(move!.fromIndex, 0);
        expect(move!.toIndex, 0);
      },
    );
  });
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
