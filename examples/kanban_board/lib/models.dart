import 'package:flutter/material.dart';

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
