import 'package:dnd_kit_jaspr/dnd_kit_jaspr.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr_test/jaspr_test.dart';

void main() {
  group('DndScope', () {
    testComponents('provides a created controller to descendants via DndScope.of', (tester) async {
      DndController? captured;
      tester.pumpComponent(
        DndScope(
          child: Builder(builder: (context) {
            captured = DndScope.of(context);
            return div([]);
          }),
        ),
      );

      expect(captured, isNotNull);
      expect(captured!.isIdle, isTrue);
    });

    testComponents('uses an injected controller instead of creating its own', (tester) async {
      final injected = DndController();
      addTearDown(injected.dispose);
      DndController? captured;

      tester.pumpComponent(
        DndScope(
          controller: injected,
          child: Builder(builder: (context) {
            captured = DndScope.of(context);
            return div([]);
          }),
        ),
      );

      expect(captured, same(injected));
    });
  });
}
