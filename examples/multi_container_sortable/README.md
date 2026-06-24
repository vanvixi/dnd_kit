# Production Multi-Container Sortable Example

This example shows the supported multi-container board/list surface built on
top of the shared `dnd_kit` interaction contract. The library now owns default
target resolution and insertion semantics, while the app still owns rendering
and state mutation.

```dart
final containers = <SortableContainer>[
  SortableContainer(
    id: const DndId('todo'),
    itemIds: const <DndId>[DndId('task-1'), DndId('task-2')],
  ),
  SortableContainer(
    id: const DndId('done'),
    itemIds: const <DndId>[DndId('task-3')],
  ),
];

SortableMultiScope(
  containers: containers,
  onMove: (move) {
    // Applications still own mutation. Remove move.activeId from
    // move.fromContainerId at move.fromIndex, then insert it into
    // move.toContainerId at move.toIndex.
  },
  child: SortableMultiContainerArea(
    id: const DndId('todo'),
    itemIds: const <DndId>[DndId('task-1'), DndId('task-2')],
    child: const SortableMultiItem(
      id: DndId('task-1'),
      child: Text('Task 1'),
    ),
  ),
)
```

Use `SortableScope` / `SortableItem` for same-container-only lists and grids.
Reach for `SortableMultiScope` when you need supported movement between
application-owned containers.
