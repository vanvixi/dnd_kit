import 'package:dnd_kit_jaspr/dnd_kit_jaspr.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr_test/jaspr_test.dart';

void main() {
  group('DndDroppable', () {
    testComponents('registers its id with the controller while mounted', (tester) async {
      final controller = DndController();
      addTearDown(controller.dispose);

      tester.pumpComponent(
        DndScope(
          controller: controller,
          child: const DndDroppable(
            id: DndId('column-1'),
            data: 'payload',
            child: RawText('drop'),
          ),
        ),
      );

      final registration = controller.registry.droppable(const DndId('column-1'));
      expect(registration, isNotNull);
      expect(registration!.data, 'payload');
      expect(registration.disabled, isFalse);
    });

    testComponents('unregisters when removed from the tree', (tester) async {
      final controller = DndController();
      addTearDown(controller.dispose);

      tester.pumpComponent(
        DndScope(
          controller: controller,
          child: _ToggleDroppable(),
        ),
      );
      expect(controller.registry.droppable(const DndId('column-1')), isNotNull);

      await tester.click(find.tag('button'));

      expect(controller.registry.droppable(const DndId('column-1')), isNull);
    });

    testComponents('builder receives visual state as drag moves over target', (tester) async {
      final controller = DndController();
      addTearDown(controller.dispose);
      DndDroppableDetails? latestDetails;

      tester.pumpComponent(
        DndScope(
          controller: controller,
          child: DndDroppable(
            id: const DndId('column-1'),
            builder: (context, droppableDetails, child) {
              latestDetails = droppableDetails;
              return Component.text(
                'droppable:${droppableDetails.isOver}:'
                '${droppableDetails.activeId?.value ?? 'none'}:'
                '${droppableDetails.session?.activeId.value ?? 'none'}',
              );
            },
            child: div([]),
          ),
        ),
      );

      expect(find.text('droppable:false:none:none'), findsOneComponent);
      expect(latestDetails?.id, const DndId('column-1'));
      expect(latestDetails?.disabled, isFalse);

      controller.registry.registerDraggable(
        const DndDraggableRegistration(id: DndId('task-1')),
      );
      controller.measuring.updateDraggableRect(
        const DndId('task-1'),
        const DndRect(left: 0, top: 0, width: 20, height: 20),
      );
      controller.measuring.updateDroppableRect(
        const DndId('column-1'),
        const DndRect(left: 100, top: 100, width: 80, height: 80),
      );

      controller.beginDrag(
        const DndSensorActivationEvent(
          activeId: DndId('task-1'),
          position: DndPoint.zero,
        ),
      );
      controller.startDrag();
      controller.moveDrag(const DndPoint(110, 110));
      await tester.pump();

      expect(find.text('droppable:true:task-1:task-1'), findsOneComponent);
      expect(latestDetails?.isOver, isTrue);
      expect(controller.overId, const DndId('column-1'));

      final endEvent = controller.endDrag();
      await tester.pump();

      expect(endEvent?.overId, const DndId('column-1'));
      expect(find.text('droppable:true:task-1:task-1'), findsOneComponent);

      controller.reset();
      await tester.pump();

      expect(find.text('droppable:false:none:none'), findsOneComponent);
    });

    testComponents('ignores disabled droppables during collision detection', (tester) async {
      final controller = DndController();
      addTearDown(controller.dispose);

      tester.pumpComponent(
        DndScope(
          controller: controller,
          child: const DndDroppable(
            id: DndId('column-1'),
            disabled: true,
            child: RawText('drop'),
          ),
        ),
      );

      controller.registry.registerDraggable(
        const DndDraggableRegistration(id: DndId('task-1')),
      );
      controller.measuring.updateDraggableRect(
        const DndId('task-1'),
        const DndRect(left: 0, top: 0, width: 20, height: 20),
      );
      controller.measuring.updateDroppableRect(
        const DndId('column-1'),
        const DndRect(left: 100, top: 100, width: 80, height: 80),
      );

      controller.beginDrag(
        const DndSensorActivationEvent(
          activeId: DndId('task-1'),
          position: DndPoint.zero,
        ),
      );
      controller.startDrag();
      final moveEvent = controller.moveDrag(const DndPoint(110, 110));

      expect(moveEvent, isNotNull);
      expect(controller.overId, isNull);
      expect(controller.endDrag()?.overId, isNull);
    });
  });
}

class _ToggleDroppable extends StatefulComponent {
  @override
  State<_ToggleDroppable> createState() => _ToggleDroppableState();
}

class _ToggleDroppableState extends State<_ToggleDroppable> {
  bool _show = true;

  @override
  Component build(BuildContext context) {
    return div([
      button(onClick: () => setState(() => _show = false), []),
      if (_show) const DndDroppable(id: DndId('column-1'), child: RawText('drop')),
    ]);
  }
}
