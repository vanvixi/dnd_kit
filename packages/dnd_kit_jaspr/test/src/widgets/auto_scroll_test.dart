import 'package:dnd_kit_jaspr/dnd_kit_jaspr.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/jaspr_test.dart';

void main() {
  group('DndAutoScroll', () {
    testComponents('renders its child with vertical default behavior', (tester) async {
      tester.pumpComponent(
        DndScope(
          child: DndAutoScroll(
            id: 'scroll-view',
            child: div([Component.text('content')]),
          ),
        ),
      );

      expect(find.text('content'), findsOneComponent);
    });

    testComponents('accepts horizontal axis without introducing a separate controller',
        (tester) async {
      final controller = DndController();
      addTearDown(controller.dispose);

      tester.pumpComponent(
        DndScope(
          controller: controller,
          child: DndAutoScroll(
            axis: DndScrollAxis.horizontal,
            controller: controller,
            child: div([Component.text('row')]),
          ),
        ),
      );

      controller.beginDrag(
        const DndSensorActivationEvent(
          activeId: DndId('task-1'),
          position: DndPoint(10, 10),
        ),
        activeRect: const DndRect(left: 0, top: 0, width: 20, height: 20),
      );
      controller.startDrag();
      controller.moveDrag(const DndPoint(50, 10));
      controller.endDrag();
      controller.reset();

      expect(find.text('row'), findsOneComponent);
      expect(controller.state, const DndIdle());
    });
  });
}
