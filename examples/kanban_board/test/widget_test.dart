import 'package:flutter/gestures.dart' show kLongPressTimeout;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanban_board/main.dart';
import 'package:kanban_board/models.dart';

void main() {
  testWidgets('renders the Kanban board example', (tester) async {
    await tester.pumpWidget(const KanbanBoardApp());

    expect(find.text('dnd_kit Kanban'), findsOneWidget);
    expect(find.text('Backlog'), findsOneWidget);
    expect(find.text('Doing'), findsOneWidget);
    expect(find.text('Write adoption brief'), findsOneWidget);
  });

  testWidgets('moves a task to another column on drop', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final snapshots = <List<KanbanColumn>>[];
    await tester.pumpWidget(
      MaterialApp(
        home: KanbanBoardExample(
          onChanged: snapshots.add,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _drag(
      tester,
      from: find.byKey(const ValueKey<String>('drag:write-brief')),
      to: find.byKey(const ValueKey<String>('column-drop:review')),
    );

    expect(snapshots, isNotEmpty);
    final review =
        snapshots.last.singleWhere((column) => column.id == 'review');
    expect(review.tasks.map((task) => task.id), contains('write-brief'));
  });

  testWidgets('reorders a task within the same column on drop', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final snapshots = <List<KanbanColumn>>[];
    await tester.pumpWidget(
      MaterialApp(
        home: KanbanBoardExample(
          onChanged: snapshots.add,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _drag(
      tester,
      from: find.byKey(const ValueKey<String>('drag:write-brief')),
      to: find.byKey(const ValueKey<String>('task:audit-drops')),
      belowTargetCenter: true,
    );

    expect(snapshots, isNotEmpty);
    final backlog =
        snapshots.last.singleWhere((column) => column.id == 'backlog');
    expect(
      backlog.tasks.map((task) => task.id).toList(),
      <String>['audit-drops', 'write-brief', 'mobile-pass'],
    );
  });

  // Regression: dropping in the gap between tasks (column droppable hit,
  // taskId == null). Old code appended to end; pointer-based logic finds
  // the correct position by comparing cursor against sorted task centers.
  testWidgets(
      'places task at correct position when dropped in gap between items',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final snapshots = <List<KanbanColumn>>[];
    await tester.pumpWidget(
      MaterialApp(
        home: KanbanBoardExample(onChanged: snapshots.add),
      ),
    );
    await tester.pumpAndSettle();

    // Initial backlog: [write-brief(0), audit-drops(1), mobile-pass(2)].
    // Drag write-brief into the 10-px padding gap between audit-drops and
    // mobile-pass. pointerWithin hits only the column droppable (taskId==null).
    // Expected: [audit-drops, write-brief, mobile-pass].
    final start = tester.getCenter(
      find.byKey(const ValueKey<String>('drag:write-brief')),
    );
    final auditRect = tester.getRect(
      find.byKey(const ValueKey<String>('task-drop:audit-drops')),
    );
    final mobileRect = tester.getRect(
      find.byKey(const ValueKey<String>('task-drop:mobile-pass')),
    );
    expect(
      mobileRect.top > auditRect.bottom,
      isTrue,
      reason: 'there must be a visible gap between task droppables',
    );
    final gapCenter = Offset(start.dx, (auditRect.bottom + mobileRect.top) / 2);

    // Hold past the activation delay so the touch drag starts; a quick swipe
    // would scroll the column instead.
    final gesture = await tester.startGesture(start);
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 10));
    await gesture.moveBy(const Offset(40, 0));
    await tester.pump();
    await gesture.moveTo(Offset.lerp(start, gapCenter, 0.55)!);
    await tester.pump();
    await gesture.moveTo(gapCenter);
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(snapshots, isNotEmpty);
    final backlog = snapshots.last.singleWhere((c) => c.id == 'backlog');
    expect(
      backlog.tasks.map((t) => t.id).toList(),
      <String>['audit-drops', 'write-brief', 'mobile-pass'],
      reason:
          'write-brief must be inserted between audit-drops and mobile-pass',
    );
  });

  // Top-half drop: cursor above target's center → insert BEFORE target.
  testWidgets('inserts before target when cursor is in top half',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final snapshots = <List<KanbanColumn>>[];
    await tester.pumpWidget(
      MaterialApp(
        home: KanbanBoardExample(onChanged: snapshots.add),
      ),
    );
    await tester.pumpAndSettle();

    // Drag audit-drops (idx 1) to 20 px ABOVE write-brief center (top half).
    // Cursor < write-brief.center.y → insertAfter = false → index = 0.
    // Expected: [audit-drops, write-brief, mobile-pass].
    final writeBriefCenter = tester.getCenter(
      find.byKey(const ValueKey<String>('task:write-brief')),
    );
    final start = tester.getCenter(
      find.byKey(const ValueKey<String>('drag:audit-drops')),
    );
    final end = Offset(start.dx, writeBriefCenter.dy - 20);

    // Hold past the activation delay so the touch drag starts; a quick swipe
    // would scroll the column instead.
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

    expect(snapshots, isNotEmpty);
    final backlog = snapshots.last.singleWhere((c) => c.id == 'backlog');
    expect(
      backlog.tasks.map((t) => t.id).toList(),
      <String>['audit-drops', 'write-brief', 'mobile-pass'],
    );
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
  // would scroll the column instead.
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
