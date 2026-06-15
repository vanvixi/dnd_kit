import 'package:dnd_kit_flutter/dnd_kit_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DndAutoScroll', () {
    testWidgets('scrolls down while dragging near the trailing edge', (tester) async {
      final controller = DndController();
      final scrollController = ScrollController();
      addTearDown(controller.dispose);
      addTearDown(scrollController.dispose);

      await tester.pumpWidget(
        _AutoScrollHarness(
          controller: controller,
          scrollController: scrollController,
        ),
      );
      await tester.pump();

      _startDrag(controller, _pointNearTrailingEdge(tester));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));

      expect(scrollController.offset, greaterThan(0));
    });

    testWidgets('uses the first descendant scrollable when no scroll controller is provided',
        (tester) async {
      final controller = DndController();
      final scrollController = ScrollController();
      addTearDown(controller.dispose);
      addTearDown(scrollController.dispose);

      await tester.pumpWidget(
        _AutoScrollHarness(
          controller: controller,
          scrollController: scrollController,
          useExplicitScrollController: false,
        ),
      );
      await tester.pump();

      _startDrag(controller, _pointNearTrailingEdge(tester));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));

      expect(scrollController.offset, greaterThan(0));
    });

    testWidgets('scrolls up while dragging near the leading edge', (tester) async {
      final controller = DndController();
      final scrollController = ScrollController(initialScrollOffset: 300);
      addTearDown(controller.dispose);
      addTearDown(scrollController.dispose);

      await tester.pumpWidget(
        _AutoScrollHarness(
          controller: controller,
          scrollController: scrollController,
        ),
      );
      await tester.pump();

      _startDrag(controller, _pointNearLeadingEdge(tester));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));

      expect(scrollController.offset, lessThan(300));
    });

    testWidgets('does not scroll when disabled', (tester) async {
      final controller = DndController();
      final scrollController = ScrollController();
      addTearDown(controller.dispose);
      addTearDown(scrollController.dispose);

      await tester.pumpWidget(
        _AutoScrollHarness(
          controller: controller,
          scrollController: scrollController,
          enabled: false,
        ),
      );
      await tester.pump();

      _startDrag(controller, _pointNearTrailingEdge(tester));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));

      expect(scrollController.offset, 0);
    });

    testWidgets('stops when dragging ends', (tester) async {
      final controller = DndController();
      final scrollController = ScrollController();
      addTearDown(controller.dispose);
      addTearDown(scrollController.dispose);

      await tester.pumpWidget(
        _AutoScrollHarness(
          controller: controller,
          scrollController: scrollController,
        ),
      );
      await tester.pump();

      _startDrag(controller, _pointNearTrailingEdge(tester));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      final offsetAfterDrag = scrollController.offset;

      controller.endDrag();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));

      expect(offsetAfterDrag, greaterThan(0));
      expect(scrollController.offset, offsetAfterDrag);
    });

    testWidgets('does not exceed scroll extents', (tester) async {
      final controller = DndController();
      final scrollController = ScrollController(initialScrollOffset: 800);
      addTearDown(controller.dispose);
      addTearDown(scrollController.dispose);

      await tester.pumpWidget(
        _AutoScrollHarness(
          controller: controller,
          scrollController: scrollController,
        ),
      );
      await tester.pump();
      scrollController.jumpTo(scrollController.position.maxScrollExtent);

      _startDrag(controller, _pointNearTrailingEdge(tester));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));

      expect(scrollController.offset, scrollController.position.maxScrollExtent);
    });
  });
}

void _startDrag(DndController controller, DndPoint position) {
  controller.beginDrag(
    DndSensorActivationEvent(
      activeId: const DndId('task-1'),
      position: position,
    ),
    activeRect: const DndRect(left: 20, top: 20, width: 40, height: 40),
  );
  controller.startDrag();
  controller.moveDrag(position);
}

DndPoint _pointNearTrailingEdge(WidgetTester tester) {
  final rect = tester.getRect(find.byType(ListView));
  return DndPoint(rect.center.dx, rect.bottom - 10);
}

DndPoint _pointNearLeadingEdge(WidgetTester tester) {
  final rect = tester.getRect(find.byType(ListView));
  return DndPoint(rect.center.dx, rect.top + 10);
}

class _AutoScrollHarness extends StatelessWidget {
  const _AutoScrollHarness({
    required this.controller,
    required this.scrollController,
    this.enabled = true,
    this.useExplicitScrollController = true,
  });

  final DndController controller;
  final ScrollController scrollController;
  final bool enabled;
  final bool useExplicitScrollController;

  @override
  Widget build(BuildContext context) {
    return DndScope(
      controller: controller,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: 200,
          height: 200,
          child: DndAutoScroll(
            enabled: enabled,
            scrollController: useExplicitScrollController ? scrollController : null,
            options: const DndAutoScrollOptions(
              edgeThreshold: 40,
              maxVelocity: 20,
            ),
            child: ListView.builder(
              controller: scrollController,
              itemExtent: 50,
              itemCount: 20,
              itemBuilder: (context, index) {
                return Text('item-$index');
              },
            ),
          ),
        ),
      ),
    );
  }
}
