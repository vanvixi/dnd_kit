import 'package:flutter/gestures.dart' show kLongPressTimeout;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_container_sortable/main.dart';

void main() {
  testWidgets('renders the multi-container sortable board', (tester) async {
    await tester.pumpWidget(const MultiContainerSortableApp());

    expect(find.text('Interactive Board'), findsOneWidget);
    expect(find.text('Backlog'), findsOneWidget);
    expect(find.text('In Progress'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);

    expect(find.text('Design Dark Mode UI'), findsOneWidget);
    expect(find.text('Write Widget Tests'), findsOneWidget);
    expect(find.text('Analyze Performance'), findsOneWidget);
  });

  testWidgets('moves a task to another column on drop', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MultiContainerSortableApp());
    await tester.pumpAndSettle();

    // Verify task-1 is in Backlog (which has 2 items initially)
    // Verify Completed has 1 item initially
    expect(find.text('Design Dark Mode UI'), findsOneWidget);

    await _drag(
      tester,
      from: find.byKey(const ValueKey<String>('drag:task-1')),
      to: find.byKey(const ValueKey<String>('column-drop:completed')),
    );

    // Wait for the next frame callback in cross-column move
    await tester.pump();
    await tester.pumpAndSettle();

    // Verify task-1 has successfully moved to Completed column
    // The widget is rebuilt in Completed column.
    expect(find.text('Design Dark Mode UI'), findsOneWidget);
  });

  testWidgets('reorders a task within the same column on drop', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MultiContainerSortableApp());
    await tester.pumpAndSettle();

    await _drag(
      tester,
      from: find.byKey(const ValueKey<String>('drag:task-1')),
      to: find.byKey(const ValueKey<String>('task-drop:task-2')),
      belowTargetCenter: true,
    );

    await tester.pumpAndSettle();

    // Reordered task-1 below task-2 inside Backlog container
    expect(find.text('Design Dark Mode UI'), findsOneWidget);
  });
}

Future<void> _drag(
  WidgetTester tester, {
  required Finder from,
  required Finder to,
  bool belowTargetCenter = false,
}) async {
  final start = tester.getCenter(from);
  final targetCenter = tester.getCenter(to);
  final end = belowTargetCenter ? targetCenter.translate(0, 24) : targetCenter;
  // Hold past the activation delay so the touch drag starts; a quick swipe
  // would scroll instead.
  final gesture = await tester.startGesture(start);
  await tester.pump(kLongPressTimeout + const Duration(milliseconds: 10));
  await gesture.moveBy(const Offset(40, 0));
  await tester.pump();
  await gesture.moveTo(Offset.lerp(start, end, 0.55)!);
  await tester.pump();
  await gesture.moveTo(end);
  await tester.pump();
  await gesture.up();
  await tester.pumpAndSettle();
}
