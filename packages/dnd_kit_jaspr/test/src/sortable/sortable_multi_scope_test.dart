import 'package:dnd_kit_jaspr/dnd_kit_jaspr.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/jaspr_test.dart';

void main() {
  group('SortableMultiScope', () {
    testComponents('provides immutable container metadata to descendants', (
      tester,
    ) async {
      SortableMultiScopeData? capturedScope;
      DndController? capturedController;

      tester.pumpComponent(
        SortableMultiScope(
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
              return const RawText('child');
            },
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

    testComponents('provides container-area data to descendants', (tester) async {
      SortableMultiContainerAreaData? capturedArea;

      tester.pumpComponent(
        SortableMultiScope(
          containers: <SortableContainer>[
            SortableContainer(
              id: const DndId('todo'),
              itemIds: const <DndId>[DndId('task-1')],
            ),
          ],
          onMove: (_) {},
          child: SortableMultiContainerArea(
            id: const DndId('todo'),
            itemIds: const <DndId>[DndId('task-1')],
            child: Builder(
              builder: (context) {
                capturedArea = SortableMultiContainerArea.of(context);
                return div([Component.text('child')]);
              },
            ),
          ),
        ),
      );

      expect(capturedArea?.id, const DndId('todo'));
      expect(capturedArea?.indexOf(const DndId('task-1')), 0);
    });
  });
}
