import 'package:dnd_kit_core/dnd_kit_core.dart';
import 'package:test/test.dart';

void main() {
  group('DndWarning', () {
    test('compares by value', () {
      const first = DndWarning(
        code: 'duplicate-draggable-id',
        message: 'Duplicate draggable id registered: DndId(drag).',
        id: DndId('drag'),
      );
      const second = DndWarning(
        code: 'duplicate-draggable-id',
        message: 'Duplicate draggable id registered: DndId(drag).',
        id: DndId('drag'),
      );

      expect(first, equals(second));
      expect(first.hashCode, equals(second.hashCode));
      expect(first.toString(), contains('DndWarning'));
    });
  });

  group('DndDraggableRegistration', () {
    test('compares by value', () {
      const first = DndDraggableRegistration(
        id: DndId('drag'),
        disabled: true,
        data: 'data',
      );
      const second = DndDraggableRegistration(
        id: DndId('drag'),
        disabled: true,
        data: 'data',
      );

      expect(first, equals(second));
      expect(first.hashCode, equals(second.hashCode));
      expect(first.toString(), contains('DndDraggableRegistration'));
    });
  });

  group('DndDroppableRegistration', () {
    test('compares by value', () {
      const first = DndDroppableRegistration(
        id: DndId('drop'),
        disabled: true,
        data: 'data',
      );
      const second = DndDroppableRegistration(
        id: DndId('drop'),
        disabled: true,
        data: 'data',
      );

      expect(first, equals(second));
      expect(first.hashCode, equals(second.hashCode));
      expect(first.toString(), contains('DndDroppableRegistration'));
    });
  });

  group('DndRegistrySnapshot', () {
    test('compares by value', () {
      final first = DndRegistrySnapshot(
        draggables: {
          const DndId('drag'): const DndDraggableRegistration(id: DndId('drag')),
        },
        droppables: {
          const DndId('drop'): const DndDroppableRegistration(id: DndId('drop')),
        },
      );
      final second = DndRegistrySnapshot(
        draggables: {
          const DndId('drag'): const DndDraggableRegistration(id: DndId('drag')),
        },
        droppables: {
          const DndId('drop'): const DndDroppableRegistration(id: DndId('drop')),
        },
      );

      expect(first, equals(second));
      expect(first.hashCode, equals(second.hashCode));
      expect(first.toString(), contains('DndRegistrySnapshot'));
    });

    test('exposes immutable map views', () {
      final snapshot = DndRegistrySnapshot(
        draggables: {
          const DndId('drag'): const DndDraggableRegistration(id: DndId('drag')),
        },
      );

      expect(
        () => snapshot.draggables[DndId('other')] =
            const DndDraggableRegistration(id: DndId('other')),
        throwsUnsupportedError,
      );
      expect(
        () => snapshot.droppables[DndId('other')] =
            const DndDroppableRegistration(id: DndId('other')),
        throwsUnsupportedError,
      );
    });
  });

  group('DndRegistry', () {
    test('registers and queries draggable and droppable entries', () {
      final registry = DndRegistry();
      const draggable = DndDraggableRegistration(id: DndId('drag'));
      const droppable = DndDroppableRegistration(id: DndId('drop'));

      registry.registerDraggable(draggable);
      registry.registerDroppable(droppable);

      expect(registry.hasDraggable(draggable.id), isTrue);
      expect(registry.hasDroppable(droppable.id), isTrue);
      expect(registry.draggable(draggable.id), draggable);
      expect(registry.droppable(droppable.id), droppable);
      expect(registry.snapshot.draggables, {draggable.id: draggable});
      expect(registry.snapshot.droppables, {droppable.id: droppable});
    });

    test('rejects duplicate draggable and droppable ids in debug mode', () {
      final warnings = <DndWarning>[];
      final registry = DndRegistry(
        diagnosticsConfig: DndDiagnosticsConfig(onWarning: warnings.add),
      )
        ..registerDraggable(const DndDraggableRegistration(id: DndId('drag')))
        ..registerDroppable(const DndDroppableRegistration(id: DndId('drop')));

      expect(
        () => registry.registerDraggable(
          const DndDraggableRegistration(id: DndId('drag')),
        ),
        throwsA(isA<AssertionError>()),
      );
      expect(
        warnings,
        contains(
          isA<DndWarning>()
              .having((warning) => warning.code, 'code', 'duplicate-draggable-id')
              .having((warning) => warning.id, 'id', const DndId('drag'))
              .having(
                (warning) => warning.message,
                'message',
                contains('Each active draggable in the same DndRegistry'),
              ),
        ),
      );

      expect(
        () => registry.registerDroppable(
          const DndDroppableRegistration(id: DndId('drop')),
        ),
        throwsA(isA<AssertionError>()),
      );
      expect(
        warnings,
        contains(
          isA<DndWarning>()
              .having((warning) => warning.code, 'code', 'duplicate-droppable-id')
              .having((warning) => warning.id, 'id', const DndId('drop'))
              .having(
                (warning) => warning.message,
                'message',
                contains('Each active droppable in the same DndRegistry'),
              ),
        ),
      );
    });

    test('updates existing entries', () {
      final registry = DndRegistry()
        ..registerDraggable(const DndDraggableRegistration(id: DndId('drag')))
        ..registerDroppable(const DndDroppableRegistration(id: DndId('drop')));
      const updatedDraggable = DndDraggableRegistration(
        id: DndId('drag'),
        disabled: true,
      );
      const updatedDroppable = DndDroppableRegistration(
        id: DndId('drop'),
        disabled: true,
      );

      registry
        ..updateDraggable(updatedDraggable)
        ..updateDroppable(updatedDroppable);

      expect(registry.draggable(updatedDraggable.id), updatedDraggable);
      expect(registry.droppable(updatedDroppable.id), updatedDroppable);
    });

    test('unregisters entries', () {
      final registry = DndRegistry()
        ..registerDraggable(const DndDraggableRegistration(id: DndId('drag')))
        ..registerDroppable(const DndDroppableRegistration(id: DndId('drop')));

      expect(
        registry.unregisterDraggable(const DndId('drag')),
        const DndDraggableRegistration(id: DndId('drag')),
      );
      expect(
        registry.unregisterDroppable(const DndId('drop')),
        const DndDroppableRegistration(id: DndId('drop')),
      );
      expect(registry.hasDraggable(const DndId('drag')), isFalse);
      expect(registry.hasDroppable(const DndId('drop')), isFalse);
    });

    test('snapshots are detached from later registry mutations', () {
      final registry = DndRegistry()
        ..registerDraggable(const DndDraggableRegistration(id: DndId('drag')));

      final snapshot = registry.snapshot;
      registry.updateDraggable(
        const DndDraggableRegistration(id: DndId('drag'), disabled: true),
      );

      expect(
        snapshot.draggables,
        {
          const DndId('drag'): const DndDraggableRegistration(id: DndId('drag')),
        },
      );
      expect(registry.draggable(const DndId('drag'))?.disabled, isTrue);
    });

    test('clear removes all entries', () {
      final registry = DndRegistry()
        ..registerDraggable(const DndDraggableRegistration(id: DndId('drag')))
        ..registerDroppable(const DndDroppableRegistration(id: DndId('drop')));

      registry.clear();

      expect(registry.draggables, isEmpty);
      expect(registry.droppables, isEmpty);
    });
  });
}
