import 'package:dnd_kit_jaspr/dnd_kit_jaspr.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr_test/jaspr_test.dart';

void main() {
  group('DndDraggable', () {
    testComponents('registers its id with the controller while mounted', (tester) async {
      final controller = DndController();
      addTearDown(controller.dispose);

      tester.pumpComponent(
        DndScope(
          controller: controller,
          child: DndDraggable(
            id: const DndId('task-1'),
            data: 'payload',
            child: div([]),
          ),
        ),
      );

      final registration = controller.registry.draggable(const DndId('task-1'));
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
          child: _Toggle(),
        ),
      );
      expect(controller.registry.draggable(const DndId('task-1')), isNotNull);

      await tester.click(find.tag('button'));

      expect(controller.registry.draggable(const DndId('task-1')), isNull);
    });
  });
}

/// Shows a draggable until its button is clicked, then removes it so the
/// draggable's state disposes and unregisters.
class _Toggle extends StatefulComponent {
  @override
  State<_Toggle> createState() => _ToggleState();
}

class _ToggleState extends State<_Toggle> {
  bool _show = true;

  @override
  Component build(BuildContext context) {
    return div([
      button(onClick: () => setState(() => _show = false), []),
      if (_show) DndDraggable(id: const DndId('task-1'), child: div([])),
    ]);
  }
}
