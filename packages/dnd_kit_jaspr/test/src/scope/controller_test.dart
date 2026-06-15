import 'package:dnd_kit_jaspr/dnd_kit_jaspr.dart';
import 'package:test/test.dart';

void main() {
  group('DndController (jaspr)', () {
    test('starts idle with an empty registry', () {
      final controller = DndController();
      addTearDown(controller.dispose);

      expect(controller.state, const DndIdle());
      expect(controller.isIdle, isTrue);
      expect(controller.isDragging, isFalse);
      expect(controller.activeId, isNull);
      expect(controller.activeSession, isNull);
      expect(controller.registry.snapshot, DndRegistrySnapshot.empty);
    });

    test('drives the shared runtime and notifies through the lifecycle', () {
      final controller = DndController();
      addTearDown(controller.dispose);
      var notificationCount = 0;
      controller.addListener(() => notificationCount += 1);

      controller.beginDrag(
        const DndSensorActivationEvent(
          activeId: DndId('task-1'),
          position: DndPoint(10, 20),
          inputKind: DndInputKind.pointer,
        ),
      );
      expect(controller.state, isA<DndPending>());
      expect(controller.activeId, const DndId('task-1'));

      final startEvent = controller.startDrag();
      expect(startEvent, isA<DndDragStartEvent>());
      expect(controller.isDragging, isTrue);

      final moveEvent = controller.moveDrag(const DndPoint(14, 25));
      expect(moveEvent?.delta, const DndPoint(4, 5));

      final endEvent = controller.endDrag(overId: const DndId('column-done'));
      expect(endEvent?.overId, const DndId('column-done'));
      expect(controller.state, isA<DndDropping>());

      controller.reset();
      expect(controller.state, const DndIdle());
      expect(notificationCount, 5);
    });

    test('surfaces duplicate-id diagnostics through the shared registry', () {
      final warnings = <DndWarning>[];
      final controller = DndController(
        diagnosticsConfig: DndDiagnosticsConfig(onWarning: warnings.add),
      );
      addTearDown(controller.dispose);

      controller.registry.registerDraggable(
        const DndDraggableRegistration(id: DndId('task-1')),
      );
      expect(
        () => controller.registry.registerDraggable(
          const DndDraggableRegistration(id: DndId('task-1')),
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
        warnings,
        contains(
          isA<DndWarning>()
              .having((warning) => warning.code, 'code', 'duplicate-draggable-id')
              .having((warning) => warning.id, 'id', const DndId('task-1')),
        ),
      );
    });
  });
}
