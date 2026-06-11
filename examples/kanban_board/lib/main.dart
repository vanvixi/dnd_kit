import 'package:dnd_kit/dnd_kit.dart';
import 'package:flutter/material.dart';

import 'collision_detector.dart';
import 'horizontal_board_auto_scroll.dart';
import 'kanban_board_utils.dart';
import 'kanban_column_view.dart';
import 'kanban_task_tile.dart';
import 'models.dart';

void main() {
  runApp(const KanbanBoardApp());
}

class KanbanBoardApp extends StatelessWidget {
  const KanbanBoardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'dnd_kit Kanban',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff2f6f73),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xfff4f1ea),
        useMaterial3: true,
      ),
      home: const KanbanBoardExample(),
    );
  }
}

class KanbanBoardExample extends StatefulWidget {
  const KanbanBoardExample({
    super.key,
    this.initialColumns = defaultKanbanColumns,
    this.onChanged,
  });

  final List<KanbanColumn> initialColumns;
  final KanbanBoardChanged? onChanged;

  @override
  State<KanbanBoardExample> createState() => _KanbanBoardExampleState();
}

class _KanbanBoardExampleState extends State<KanbanBoardExample> {
  late List<KanbanColumn> _columns;
  late DndController _controller;
  late ScrollController _boardScrollController;

  @override
  void initState() {
    super.initState();
    _columns = cloneColumns(widget.initialColumns);
    _controller =
        DndController(collisionDetector: kanbanBoardCollisionDetector);
    _boardScrollController = ScrollController();
  }

  @override
  void didUpdateWidget(KanbanBoardExample oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialColumns != widget.initialColumns) {
      _columns = cloneColumns(widget.initialColumns);
    }
  }

  @override
  void dispose() {
    _boardScrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleDragEnd(DndDragEndEvent event) {
    final dragData = _controller.registry.draggable(event.activeId)?.data;
    final overId = event.overId;
    final dropData =
        overId == null ? null : _controller.registry.droppable(overId)?.data;
    if (dragData is! KanbanTaskDragData || dropData is! KanbanDropData) {
      _controller.reset();
      return;
    }

    final targetRect = _controller.measuring.droppableRect(overId!);
    final insertAfter = dropData.taskId != null &&
        targetRect != null &&
        event.currentPointer.y > targetRect.center.y;

    _moveTask(
      taskId: dragData.taskId,
      fromColumnId: dragData.columnId,
      toColumnId: dropData.columnId,
      targetTaskId: dropData.taskId,
      insertAfter: insertAfter,
    );
    _controller.reset();
  }

  void _moveTask({
    required String taskId,
    required String fromColumnId,
    required String toColumnId,
    required String? targetTaskId,
    required bool insertAfter,
  }) {
    if (fromColumnId == toColumnId && taskId == targetTaskId) {
      return;
    }

    final nextColumns = _columns.map((column) => column.copyWith()).toList();
    final fromIndex =
        nextColumns.indexWhere((column) => column.id == fromColumnId);
    final toIndex = nextColumns.indexWhere((column) => column.id == toColumnId);
    if (fromIndex == -1 || toIndex == -1) {
      return;
    }

    final fromTasks = nextColumns[fromIndex].tasks.toList();
    final taskIndex = fromTasks.indexWhere((task) => task.id == taskId);
    if (taskIndex == -1) {
      return;
    }

    final task = fromTasks.removeAt(taskIndex);
    nextColumns[fromIndex] = nextColumns[fromIndex].copyWith(tasks: fromTasks);

    if (fromColumnId != toColumnId) {
      setState(() {
        _columns = List<KanbanColumn>.unmodifiable(nextColumns);
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _insertTask(
          task: task,
          toColumnId: toColumnId,
          targetTaskId: targetTaskId,
          insertAfter: insertAfter,
        );
      });
      return;
    }

    final targetTasks = nextColumns[toIndex].tasks.toList();
    _insertTaskIntoList(
      targetTasks,
      task: task,
      targetTaskId: targetTaskId,
      insertAfter: insertAfter,
    );
    nextColumns[toIndex] = nextColumns[toIndex].copyWith(tasks: targetTasks);

    setState(() {
      _columns = List<KanbanColumn>.unmodifiable(nextColumns);
    });
    widget.onChanged?.call(_columns);
  }

  void _insertTask({
    required KanbanTask task,
    required String toColumnId,
    required String? targetTaskId,
    required bool insertAfter,
  }) {
    final nextColumns = _columns.map((column) => column.copyWith()).toList();
    final toIndex = nextColumns.indexWhere((column) => column.id == toColumnId);
    if (toIndex == -1) {
      return;
    }

    final targetTasks = nextColumns[toIndex].tasks.toList();
    _insertTaskIntoList(
      targetTasks,
      task: task,
      targetTaskId: targetTaskId,
      insertAfter: insertAfter,
    );
    nextColumns[toIndex] = nextColumns[toIndex].copyWith(tasks: targetTasks);

    setState(() {
      _columns = List<KanbanColumn>.unmodifiable(nextColumns);
    });
    widget.onChanged?.call(_columns);
  }

  void _insertTaskIntoList(
    List<KanbanTask> targetTasks, {
    required KanbanTask task,
    required String? targetTaskId,
    required bool insertAfter,
  }) {
    var insertionIndex = targetTaskId == null
        ? targetTasks.length
        : targetTasks.indexWhere((task) => task.id == targetTaskId);
    if (insertionIndex == -1) {
      insertionIndex = targetTasks.length;
    }
    if (insertAfter && targetTaskId != null) {
      insertionIndex += 1;
    }
    insertionIndex = insertionIndex.clamp(0, targetTasks.length);
    targetTasks.insert(insertionIndex, task);
  }

  KanbanTask? _taskFor(DndId id) {
    final taskId = taskIdFromDndId(id);
    if (taskId == null) {
      return null;
    }

    for (final column in _columns) {
      for (final task in column.tasks) {
        if (task.id == taskId) {
          return task;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return DndScope(
      controller: _controller,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('dnd_kit Kanban'),
          actions: const <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 20),
              child: Icon(Icons.view_kanban_outlined),
            ),
          ],
        ),
        body: Stack(
          children: <Widget>[
            HorizontalBoardAutoScroll(
              controller: _controller,
              scrollController: _boardScrollController,
              child: SingleChildScrollView(
                key: const ValueKey<String>('kanban-board-scroll'),
                controller: _boardScrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    for (var index = 0;
                        index < _columns.length;
                        index += 1) ...<Widget>[
                      KanbanColumnView(
                        key: ValueKey<String>(
                            'column-view:${_columns[index].id}'),
                        column: _columns[index],
                        onDragEnd: _handleDragEnd,
                      ),
                      if (index != _columns.length - 1)
                        const SizedBox(width: 16),
                    ],
                  ],
                ),
              ),
            ),
            DndDragOverlay(
              controller: _controller,
              builder: (context, details) {
                final task = _taskFor(details.activeId);
                if (task == null) {
                  return const SizedBox.shrink();
                }
                return KanbanTaskCard(
                  task: task,
                  elevated: true,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
