import 'dart:math' as math;

import 'package:dnd_kit/dnd_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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

@immutable
final class KanbanTask {
  const KanbanTask({
    required this.id,
    required this.title,
    required this.owner,
    required this.accent,
  });

  final String id;
  final String title;
  final String owner;
  final Color accent;
}

@immutable
final class KanbanColumn {
  const KanbanColumn({
    required this.id,
    required this.title,
    required this.tasks,
  });

  final String id;
  final String title;
  final List<KanbanTask> tasks;

  KanbanColumn copyWith({List<KanbanTask>? tasks}) {
    return KanbanColumn(
      id: id,
      title: title,
      tasks: List<KanbanTask>.unmodifiable(tasks ?? this.tasks),
    );
  }
}

@immutable
final class KanbanTaskDragData {
  const KanbanTaskDragData({
    required this.columnId,
    required this.taskId,
  });

  final String columnId;
  final String taskId;
}

@immutable
final class KanbanDropData {
  const KanbanDropData({
    required this.columnId,
    this.taskId,
  });

  final String columnId;
  final String? taskId;
}

typedef KanbanBoardChanged = void Function(List<KanbanColumn> columns);

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
    _columns = _cloneColumns(widget.initialColumns);
    _controller =
        DndController(collisionDetector: kanbanBoardCollisionDetector);
    _boardScrollController = ScrollController();
  }

  @override
  void didUpdateWidget(KanbanBoardExample oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialColumns != widget.initialColumns) {
      _columns = _cloneColumns(widget.initialColumns);
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
    final taskId = _taskIdFromDndId(id);
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
            _HorizontalBoardAutoScroll(
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
                      _KanbanColumnView(
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
                return _KanbanTaskCard(
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

class _KanbanColumnView extends StatefulWidget {
  const _KanbanColumnView({
    super.key,
    required this.column,
    required this.onDragEnd,
  });

  final KanbanColumn column;
  final DndDragEndCallback onDragEnd;

  @override
  State<_KanbanColumnView> createState() => _KanbanColumnViewState();
}

class _KanbanColumnViewState extends State<_KanbanColumnView> {
  late final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: ValueKey<String>('column:${widget.column.id}'),
      width: 320,
      child: DndDroppable(
        id: _columnDndId(widget.column.id),
        data: KanbanDropData(columnId: widget.column.id),
        builder: (context, details, child) {
          return AnimatedContainer(
            key: ValueKey<String>('column-drop:${widget.column.id}'),
            duration: const Duration(milliseconds: 120),
            decoration: BoxDecoration(
              color: details.isOver
                  ? const Color(0xfffffbef)
                  : const Color(0xffffffff),
              border: Border.all(
                color: details.isOver
                    ? const Color(0xff2f6f73)
                    : const Color(0xffddd6c8),
                width: details.isOver ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: child,
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      widget.column.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  Text(
                    '${widget.column.tasks.length}',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: DndAutoScroll(
                scrollController: _scrollController,
                options: const DndAutoScrollOptions(
                  edgeThreshold: 72,
                  maxVelocity: 12,
                ),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: <Widget>[
                      for (var index = 0;
                          index < widget.column.tasks.length;
                          index += 1)
                        Padding(
                          key: ValueKey<String>(
                            'task-padding:${widget.column.tasks[index].id}',
                          ),
                          padding: EdgeInsets.only(
                            bottom: index == widget.column.tasks.length - 1
                                ? 0
                                : 10,
                          ),
                          child: _KanbanTaskTile(
                            key: ValueKey<String>(
                              'task-tile:${widget.column.tasks[index].id}',
                            ),
                            columnId: widget.column.id,
                            task: widget.column.tasks[index],
                            onDragEnd: widget.onDragEnd,
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
    );
  }
}

class _KanbanTaskTile extends StatelessWidget {
  const _KanbanTaskTile({
    super.key,
    required this.columnId,
    required this.task,
    required this.onDragEnd,
  });

  final String columnId;
  final KanbanTask task;
  final DndDragEndCallback onDragEnd;

  @override
  Widget build(BuildContext context) {
    final taskDndId = _taskDndId(task.id);
    return DndDroppable(
      key: ValueKey<String>('task-drop:${task.id}'),
      id: taskDndId,
      data: KanbanDropData(
        columnId: columnId,
        taskId: task.id,
      ),
      builder: (context, details, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          decoration: BoxDecoration(
            border: Border.all(
              color:
                  details.isOver ? const Color(0xff2f6f73) : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: child,
        );
      },
      child: DndDraggable(
        key: ValueKey<String>('drag:${task.id}'),
        id: taskDndId,
        data: KanbanTaskDragData(
          columnId: columnId,
          taskId: task.id,
        ),
        activationConstraint: const DndSensorActivationConstraint(distance: 4),
        onDragEnd: onDragEnd,
        builder: (context, details, child) {
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 100),
            opacity: details.isDragging ? 0.36 : 1,
            child: child,
          );
        },
        child: _KanbanTaskCard(
          key: ValueKey<String>('task:${task.id}'),
          task: task,
        ),
      ),
    );
  }
}

class _KanbanTaskCard extends StatelessWidget {
  const _KanbanTaskCard({
    super.key,
    required this.task,
    this.elevated = false,
  });

  final KanbanTask task;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xffffffff),
      elevation: elevated ? 8 : 1,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: const BoxConstraints(minHeight: 88),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: task.accent,
              width: 4,
            ),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              task.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Icon(
                  Icons.person_outline,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    task.owner,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HorizontalBoardAutoScroll extends StatefulWidget {
  const _HorizontalBoardAutoScroll({
    required this.controller,
    required this.scrollController,
    required this.child,
  });

  final DndController controller;
  final ScrollController scrollController;
  final Widget child;

  @override
  State<_HorizontalBoardAutoScroll> createState() =>
      _HorizontalBoardAutoScrollState();
}

class _HorizontalBoardAutoScrollState extends State<_HorizontalBoardAutoScroll>
    with SingleTickerProviderStateMixin {
  final GlobalKey _viewportKey = GlobalKey();
  late final Ticker _ticker;
  DndPoint? _pointer;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick);
    widget.controller.addListener(_syncAutoScroll);
  }

  @override
  void didUpdateWidget(_HorizontalBoardAutoScroll oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_syncAutoScroll);
      widget.controller.addListener(_syncAutoScroll);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncAutoScroll);
    _ticker.dispose();
    super.dispose();
  }

  void _syncAutoScroll() {
    final session = widget.controller.activeSession;
    if (session == null || !widget.controller.isDragging) {
      _stop();
      return;
    }

    _pointer = session.currentPointer;
    if (_velocityFor(session.currentPointer) == 0) {
      _stop();
      return;
    }

    if (!_ticker.isActive) {
      _ticker.start();
    }
  }

  void _tick(Duration elapsed) {
    final pointer = _pointer;
    if (pointer == null || !widget.scrollController.hasClients) {
      _stop();
      return;
    }

    final velocity = _velocityFor(pointer);
    if (velocity == 0) {
      _stop();
      return;
    }

    final position = widget.scrollController.position;
    final nextPixels = (position.pixels + velocity).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if (nextPixels == position.pixels) {
      _stop();
      return;
    }
    position.jumpTo(nextPixels);
  }

  double _velocityFor(DndPoint pointer) {
    if (!widget.scrollController.hasClients) {
      return 0;
    }

    final box = _viewportKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) {
      return 0;
    }

    final localPointer = box.globalToLocal(Offset(pointer.x, pointer.y));
    if (localPointer.dy < 0 ||
        localPointer.dy > box.size.height ||
        localPointer.dx < 0 ||
        localPointer.dx > box.size.width) {
      return 0;
    }

    const edgeThreshold = 96.0;
    const maxVelocity = 14.0;
    final position = widget.scrollController.position;
    if (localPointer.dx < edgeThreshold &&
        position.pixels > position.minScrollExtent) {
      return -maxVelocity * ((edgeThreshold - localPointer.dx) / edgeThreshold);
    }

    final trailingDistance = box.size.width - localPointer.dx;
    if (trailingDistance < edgeThreshold &&
        position.pixels < position.maxScrollExtent) {
      return maxVelocity * ((edgeThreshold - trailingDistance) / edgeThreshold);
    }

    return 0;
  }

  void _stop() {
    _pointer = null;
    if (_ticker.isActive) {
      _ticker.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: _viewportKey,
      decoration: const BoxDecoration(),
      child: widget.child,
    );
  }
}

DndCollisionResult kanbanBoardCollisionDetector(DndCollisionInput input) {
  final pointerWithin = DndCollisionDetectors.pointerWithin(input);
  if (pointerWithin.isNotEmpty) {
    final taskResult = DndCollisionResult(
      pointerWithin.collisions.where(
        (collision) => collision.id.value.startsWith('task:'),
      ),
    );
    if (taskResult.isNotEmpty) {
      return taskResult;
    }
    return pointerWithin;
  }

  final closest = DndCollisionDetectors.closestCenter(input);
  return DndCollisionResult(
    closest.collisions.take(math.min(closest.collisions.length, 3)),
  );
}

List<KanbanColumn> _cloneColumns(List<KanbanColumn> columns) {
  return List<KanbanColumn>.unmodifiable(
    columns.map((column) => column.copyWith(tasks: column.tasks.toList())),
  );
}

DndId _columnDndId(String id) => DndId('column:$id');

DndId _taskDndId(String id) => DndId('task:$id');

String? _taskIdFromDndId(DndId id) {
  const prefix = 'task:';
  return id.value.startsWith(prefix) ? id.value.substring(prefix.length) : null;
}

const List<KanbanColumn> defaultKanbanColumns = <KanbanColumn>[
  KanbanColumn(
    id: 'backlog',
    title: 'Backlog',
    tasks: <KanbanTask>[
      KanbanTask(
        id: 'write-brief',
        title: 'Write adoption brief',
        owner: 'Mina',
        accent: Color(0xff2f6f73),
      ),
      KanbanTask(
        id: 'audit-drops',
        title: 'Audit drop target states',
        owner: 'Sora',
        accent: Color(0xffb76e35),
      ),
      KanbanTask(
        id: 'mobile-pass',
        title: 'Mobile long-press pass',
        owner: 'Kai',
        accent: Color(0xff6d5fa8),
      ),
    ],
  ),
  KanbanColumn(
    id: 'doing',
    title: 'Doing',
    tasks: <KanbanTask>[
      KanbanTask(
        id: 'wire-overlay',
        title: 'Wire drag overlay polish',
        owner: 'An',
        accent: Color(0xff3f7cac),
      ),
      KanbanTask(
        id: 'scroll-tuning',
        title: 'Tune edge auto-scroll',
        owner: 'Davi',
        accent: Color(0xffc84630),
      ),
    ],
  ),
  KanbanColumn(
    id: 'review',
    title: 'In Review',
    tasks: <KanbanTask>[
      KanbanTask(
        id: 'collision-demo',
        title: 'Custom collision demo',
        owner: 'Linh',
        accent: Color(0xff9a7b4f),
      ),
    ],
  ),
  KanbanColumn(
    id: 'done',
    title: 'Done',
    tasks: <KanbanTask>[
      KanbanTask(
        id: 'sortable-grid',
        title: 'Sortable grid foundation',
        owner: 'Noah',
        accent: Color(0xff4f7f52),
      ),
    ],
  ),
];
