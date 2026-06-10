# API Principles

## Flutter-Style Naming

Use Flutter-native names:

- `DndScope`
- `DndController`
- `DndDraggable`
- `DndDroppable`
- `DndDragHandle`
- `DndDragOverlay`
- `SortableScope`
- `SortableItem`

Avoid React-specific API shapes such as `DndContext`, `useDraggable`,
`useDroppable`, or hook-style naming.

## Controlled And Uncontrolled Scope

`DndScope` must support both lifecycle modes.

Uncontrolled:

```dart
DndScope(
  child: App(),
)
```

Controlled:

```dart
final controller = DndController();

DndScope(
  controller: controller,
  child: App(),
)
```

Rules:

- If the user provides a controller, the user owns its lifecycle.
- If no controller is provided, `DndScope` creates and disposes an internal
  controller.
- `DndScope` must never dispose an external controller.

## Users Own Data

The library reports drag/drop intent. It must not mutate user collections,
tasks, boards, or app state.

Sortable callbacks provide enough information for the user to mutate their own
data with `setState`, Riverpod, BLoC, Provider, Redux, or any other approach.

## Stable IDs

`DndId` wraps an application-owned `String` value. The value must be stable
during the widget lifecycle and is compared as an exact string match.

The library does not trim, case-fold, normalize, parse, or namespace ID values.
Applications should pass the same canonical string they use to identify the
underlying item, container, or user-owned entity.

Prefer:

```dart
DndId(task.id)
DndId('column-todo')
DndId(user.id)
DndId('column:${column.id}/task:${task.id}')
```

Avoid:

```dart
DndId('')
DndId('   ')
DndId(UniqueKey().toString())
DndId(DateTime.now().toIso8601String())
DndId(Object().toString())
```

Empty values are invalid. Whitespace-only values should be treated as invalid
by application code because they make diagnostics and duplicate detection hard
to understand.

Duplicate IDs inside a registry should be caught by debug diagnostics.
Recoverable registry diagnostics should also be available through
`DndDiagnosticsConfig.onWarning` so applications can surface actionable
warnings without depending only on debug assertions.

## Performance Principles

- Do not rebuild the whole app on every pointer move.
- Update overlays independently from source layout.
- Cache measuring data during drag where possible.
- Run collision detection at most once per frame.
- Keep core algorithms testable without Flutter.
