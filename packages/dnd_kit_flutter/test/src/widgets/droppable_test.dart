import 'package:dnd_kit_core/dnd_kit_core.dart';
import 'package:dnd_kit_flutter/dnd_kit_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DndDroppable', () {
    testWidgets('registers and unregisters droppable metadata', (tester) async {
      final controller = DndController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        DndScope(
          controller: controller,
          child: const DndDroppable(
            id: DndId('column-1'),
            data: 'payload',
            child: SizedBox(width: 80, height: 80),
          ),
        ),
      );

      expect(
        controller.registry.droppable(const DndId('column-1')),
        const DndDroppableRegistration(
          id: DndId('column-1'),
          data: 'payload',
        ),
      );

      await tester.pumpWidget(
        DndScope(
          controller: controller,
          child: const SizedBox(),
        ),
      );

      expect(controller.registry.hasDroppable(const DndId('column-1')), isFalse);
    });

    testWidgets('updates registry metadata when widget inputs change', (tester) async {
      final controller = DndController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        DndScope(
          controller: controller,
          child: const DndDroppable(
            id: DndId('column-1'),
            data: 'first',
            child: SizedBox(width: 80, height: 80),
          ),
        ),
      );

      await tester.pumpWidget(
        DndScope(
          controller: controller,
          child: const DndDroppable(
            id: DndId('column-2'),
            disabled: true,
            data: 'second',
            child: SizedBox(width: 80, height: 80),
          ),
        ),
      );

      expect(controller.registry.hasDroppable(const DndId('column-1')), isFalse);
      expect(
        controller.registry.droppable(const DndId('column-2')),
        const DndDroppableRegistration(
          id: DndId('column-2'),
          disabled: true,
          data: 'second',
        ),
      );
    });

    testWidgets('moves registration when the nearest controller changes', (tester) async {
      final firstController = DndController();
      final secondController = DndController();
      addTearDown(firstController.dispose);
      addTearDown(secondController.dispose);

      await tester.pumpWidget(
        DndScope(
          controller: firstController,
          child: const DndDroppable(
            id: DndId('column-1'),
            child: SizedBox(width: 80, height: 80),
          ),
        ),
      );

      await tester.pumpWidget(
        DndScope(
          controller: secondController,
          child: const DndDroppable(
            id: DndId('column-1'),
            child: SizedBox(width: 80, height: 80),
          ),
        ),
      );

      expect(firstController.registry.hasDroppable(const DndId('column-1')), isFalse);
      expect(secondController.registry.hasDroppable(const DndId('column-1')), isTrue);
    });

    testWidgets('keeps disabled droppables registered as disabled metadata', (tester) async {
      final controller = DndController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        DndScope(
          controller: controller,
          child: const DndDroppable(
            id: DndId('column-1'),
            disabled: true,
            child: SizedBox(width: 80, height: 80),
          ),
        ),
      );

      expect(
        controller.registry.droppable(const DndId('column-1'))?.disabled,
        isTrue,
      );
    });

    testWidgets('measures global droppable bounds while mounted', (tester) async {
      final controller = DndController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        DndScope(
          controller: controller,
          child: const Stack(
            textDirection: TextDirection.ltr,
            children: <Widget>[
              Positioned(
                left: 10,
                top: 20,
                child: DndDroppable(
                  id: DndId('column-1'),
                  child: SizedBox(width: 80, height: 60),
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      expect(
        controller.measuring.droppableRect(const DndId('column-1')),
        const DndRect(left: 10, top: 20, width: 80, height: 60),
      );

      await tester.pumpWidget(
        DndScope(
          controller: controller,
          child: const SizedBox(),
        ),
      );

      expect(controller.measuring.droppableRect(const DndId('column-1')), isNull);
    });

    testWidgets('removes old measurements and measures the new id after id changes',
        (tester) async {
      final controller = DndController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        DndScope(
          controller: controller,
          child: const Stack(
            textDirection: TextDirection.ltr,
            children: <Widget>[
              Positioned(
                left: 0,
                top: 0,
                child: DndDroppable(
                  id: DndId('column-1'),
                  child: SizedBox(width: 80, height: 60),
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      expect(controller.measuring.droppableStatus(const DndId('column-1')),
          DndMeasurementStatus.clean);

      await tester.pumpWidget(
        DndScope(
          controller: controller,
          child: const Stack(
            textDirection: TextDirection.ltr,
            children: <Widget>[
              Positioned(
                left: 0,
                top: 0,
                child: DndDroppable(
                  id: DndId('column-2'),
                  child: SizedBox(width: 100, height: 70),
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      expect(controller.measuring.droppableStatus(const DndId('column-1')),
          DndMeasurementStatus.removed);
      expect(controller.measuring.droppableStatus(const DndId('column-2')),
          DndMeasurementStatus.clean);
      expect(
        controller.measuring.droppableRect(const DndId('column-2')),
        const DndRect(left: 0, top: 0, width: 100, height: 70),
      );
    });

    testWidgets('marks disabled changes dirty while keeping stale rects out of collision',
        (tester) async {
      final controller = DndController();
      addTearDown(controller.dispose);
      DndDragEndEvent? endEvent;

      await tester.pumpWidget(
        DndScope(
          controller: controller,
          child: Stack(
            textDirection: TextDirection.ltr,
            children: <Widget>[
              const Positioned(
                left: 100,
                top: 0,
                child: DndDroppable(
                  id: DndId('column-1'),
                  child: SizedBox(width: 80, height: 80),
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                child: DndDraggable(
                  id: const DndId('task-1'),
                  onDragEnd: (event) {
                    endEvent = event;
                  },
                  child: const SizedBox(width: 40, height: 40),
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      await tester.pumpWidget(
        DndScope(
          controller: controller,
          child: Stack(
            textDirection: TextDirection.ltr,
            children: <Widget>[
              const Positioned(
                left: 100,
                top: 0,
                child: DndDroppable(
                  id: DndId('column-1'),
                  disabled: true,
                  child: SizedBox(width: 80, height: 80),
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                child: DndDraggable(
                  id: const DndId('task-1'),
                  onDragEnd: (event) {
                    endEvent = event;
                  },
                  child: const SizedBox(width: 40, height: 40),
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      expect(controller.registry.droppable(const DndId('column-1'))?.disabled, isTrue);
      expect(controller.measuring.droppableRect(const DndId('column-1')), isNotNull);

      await tester.dragFrom(const Offset(20, 20), const Offset(100, 0));
      await tester.pump();

      expect(endEvent?.overId, isNull);
    });
  });
}
