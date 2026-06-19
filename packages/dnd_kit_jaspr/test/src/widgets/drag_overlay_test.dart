import 'package:dnd_kit_jaspr/dnd_kit_jaspr.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/jaspr_test.dart';

void main() {
  group('DndDragOverlay', () {
    testComponents('renders nothing when no active session exists', (tester) async {
      final controller = DndController();
      addTearDown(controller.dispose);

      tester.pumpComponent(
        DndScope(
          controller: controller,
          child: DndDragOverlay(
            builder: (context, details) {
              return Component.text('overlay');
            },
          ),
        ),
      );

      expect(find.text('overlay'), findsNothing);

      controller.beginDrag(
        const DndSensorActivationEvent(
          activeId: DndId('task-1'),
          position: DndPoint(10, 10),
        ),
        activeRect: const DndRect(left: 20, top: 30, width: 40, height: 50),
      );
      await tester.pump();

      expect(find.text('overlay'), findsNothing);
    });

    testComponents('renders active details while dragging', (tester) async {
      final controller = DndController();
      addTearDown(controller.dispose);
      DndDragOverlayDetails? latestDetails;

      tester.pumpComponent(
        DndScope(
          controller: controller,
          child: DndDragOverlay(
            builder: (context, details) {
              latestDetails = details;
              return Component.text(
                'overlay:${details.activeId.value}:${details.transform.x}',
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
      await tester.pump();

      expect(find.text('overlay:task-1:0.0'), findsOneComponent);
      expect(latestDetails?.activeId, const DndId('task-1'));
      expect(
        latestDetails?.activeRect,
        const DndRect(left: 20, top: 30, width: 40, height: 50),
      );

      controller.moveDrag(const DndPoint(25, 35));
      await tester.pump();

      expect(find.text('overlay:task-1:15.0'), findsOneComponent);
      expect(latestDetails?.transform, const DndTransform(x: 15, y: 25));
    });

    testComponents('rebinds to a replaced scope controller', (tester) async {
      final controllerA = DndController();
      final controllerB = DndController();
      addTearDown(controllerA.dispose);
      addTearDown(controllerB.dispose);

      Component tree(DndController controller) {
        return DndScope(
          controller: controller,
          child: DndDragOverlay(
            builder: (context, details) {
              return Component.text(
                'overlay:${details.activeId.value}:${details.transform.x}',
              );
            },
          ),
        );
      }

      tester.pumpComponent(tree(controllerA));

      controllerA.beginDrag(
        const DndSensorActivationEvent(
          activeId: DndId('task-a'),
          position: DndPoint(10, 10),
        ),
        activeRect: const DndRect(left: 20, top: 30, width: 40, height: 50),
      );
      controllerA.startDrag();
      await tester.pump();

      expect(find.text('overlay:task-a:0.0'), findsOneComponent);

      controllerA.cancelDrag();
      await tester.pump();
      controllerA.reset();
      await tester.pump();
      expect(find.text('overlay:task-a:0.0'), findsNothing);

      tester.pumpComponent(tree(controllerB));

      controllerB.beginDrag(
        const DndSensorActivationEvent(
          activeId: DndId('task-b'),
          position: DndPoint(10, 10),
        ),
        activeRect: const DndRect(left: 20, top: 30, width: 40, height: 50),
      );
      controllerB.startDrag();
      await tester.pump();

      expect(find.text('overlay:task-b:0.0'), findsOneComponent);
    });
  });
}
