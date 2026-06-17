import 'package:dnd_kit_jaspr/dnd_kit_jaspr.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr_test/jaspr_test.dart';

const _a = DndId('a');
const _b = DndId('b');

void main() {
  group('SortableItem', () {
    testComponents('registers both a draggable and a droppable while mounted', (tester) async {
      final controller = DndController();
      addTearDown(controller.dispose);

      tester.pumpComponent(
        SortableScope(
          controller: controller,
          itemIds: const [_a, _b],
          child: div([
            const SortableItem(id: _a, data: 'payload', child: RawText('a')),
            const SortableItem(id: _b, child: RawText('b')),
          ]),
        ),
      );

      expect(controller.registry.hasDraggable(_a), isTrue);
      expect(controller.registry.hasDroppable(_a), isTrue);
      expect(controller.registry.hasDraggable(_b), isTrue);
      expect(controller.registry.hasDroppable(_b), isTrue);
      expect(controller.registry.draggable(_a)!.data, 'payload');
    });

    testComponents('builder receives live state and index as a drag moves over it', (tester) async {
      final controller = DndController();
      addTearDown(controller.dispose);
      SortableItemDetails? bDetails;

      tester.pumpComponent(
        SortableScope(
          controller: controller,
          itemIds: const [_a, _b],
          child: div([
            const SortableItem(id: _a, child: RawText('a')),
            SortableItem(
              id: _b,
              builder: (context, itemDetails, child) {
                bDetails = itemDetails;
                return Component.text(
                  'b:${itemDetails.index}:${itemDetails.isOver}:${itemDetails.isActive}',
                );
              },
              child: const RawText('b'),
            ),
          ]),
        ),
      );

      expect(find.text('b:1:false:false'), findsOneComponent);
      expect(bDetails!.index, 1);

      // Item a registers its draggable rect; b registers its droppable rect.
      controller.measuring.updateDraggableRect(
        _a,
        const DndRect(left: 0, top: 0, width: 20, height: 20),
      );
      controller.measuring.updateDroppableRect(
        _b,
        const DndRect(left: 0, top: 60, width: 20, height: 20),
      );

      controller.beginDrag(
        const DndSensorActivationEvent(activeId: _a, position: DndPoint.zero),
      );
      controller.startDrag();
      controller.moveDrag(const DndPoint(10, 70));
      await tester.pump();

      expect(controller.overId, _b);
      expect(bDetails!.isOver, isTrue);
      expect(bDetails!.isActive, isFalse);
      expect(find.text('b:1:true:false'), findsOneComponent);
    });
  });
}
