import 'package:dnd_kit_flutter/dnd_kit_flutter.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SortableMultiScope', () {
    testWidgets('provides immutable container metadata and a drag controller', (
      tester,
    ) async {
      SortableMultiScopeData? capturedScope;
      DndController? capturedController;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SortableMultiScope(
            containers: <SortableContainer>[
              SortableContainer(
                id: const DndId('todo'),
                itemIds: const <DndId>[DndId('task-1')],
              ),
            ],
            onMove: (_) {},
            child: Builder(
              builder: (context) {
                capturedScope = SortableMultiScope.of(context);
                capturedController = DndScope.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(capturedController, isNotNull);
      expect(capturedScope?.containers.single.id, const DndId('todo'));
      expect(
        () => capturedScope?.containers.add(
          SortableContainer(
            id: const DndId('done'),
            itemIds: const <DndId>[],
          ),
        ),
        throwsUnsupportedError,
      );
    });

    testWidgets('reports cross-container moves without manual drag-end wiring', (
      tester,
    ) async {
      final moves = <SortableMoveDetails>[];
      final containers = <SortableContainer>[
        SortableContainer(
          id: const DndId('todo'),
          itemIds: const <DndId>[DndId('task-1')],
        ),
        SortableContainer(
          id: const DndId('done'),
          itemIds: const <DndId>[DndId('task-2')],
        ),
      ];

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 260,
            height: 140,
            child: SortableMultiScope(
              containers: containers,
              onMove: moves.add,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    left: 0,
                    top: 0,
                    child: SortableMultiContainerArea(
                      id: const DndId('todo'),
                      itemIds: const <DndId>[DndId('task-1')],
                      child: SizedBox(
                        width: 120,
                        height: 120,
                        child: Stack(
                          children: const <Widget>[
                            Positioned(
                              left: 0,
                              top: 0,
                              child: SortableMultiItem(
                                id: DndId('task-1'),
                                child: SizedBox(width: 80, height: 40),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 140,
                    top: 0,
                    child: SortableMultiContainerArea(
                      id: const DndId('done'),
                      itemIds: const <DndId>[DndId('task-2')],
                      child: SizedBox(
                        width: 120,
                        height: 120,
                        child: Stack(
                          children: const <Widget>[
                            Positioned(
                              left: 0,
                              top: 0,
                              child: SortableMultiItem(
                                id: DndId('task-2'),
                                child: SizedBox(width: 80, height: 40),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.dragFrom(
        const Offset(40, 20),
        const Offset(140, 0),
        kind: PointerDeviceKind.mouse,
      );
      await tester.pump();

      expect(moves, hasLength(1));
      expect(
        moves.single,
        isA<SortableMoveDetails>()
            .having((details) => details.activeId, 'activeId', const DndId('task-1'))
            .having((details) => details.overId, 'overId', const DndId('task-2'))
            .having((details) => details.fromContainerId, 'fromContainerId', const DndId('todo'))
            .having((details) => details.toContainerId, 'toContainerId', const DndId('done'))
            .having((details) => details.fromIndex, 'fromIndex', 0)
            .having((details) => details.toIndex, 'toIndex', 0),
      );
    });
  });
}
