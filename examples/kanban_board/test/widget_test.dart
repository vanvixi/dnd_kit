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
  final gesture = await tester.startGesture(start);
  await tester.pump();
  await gesture.moveBy(const Offset(40, 0));
  await tester.pump();
  await gesture.moveTo(Offset.lerp(start, end, 0.55)!);
  await tester.pump();
  await gesture.moveTo(end);
  await tester.pump();
  await gesture.up();
  await tester.pumpAndSettle();
}
