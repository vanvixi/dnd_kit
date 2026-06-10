# Kanban Board Example

Showcase app for building a Kanban board with the generic `dnd_kit` Flutter
APIs.

The example uses:

- `DndScope`;
- `DndDraggable`;
- `DndDroppable`;
- `DndDragOverlay`;
- drag source opacity and drop target highlights;
- vertical column auto-scroll and horizontal board auto-scroll;
- a custom Kanban-oriented collision detector.

Run it from the repository root with:

```bash
fvm flutter run -d chrome examples/kanban_board
```

Run its widget tests with:

```bash
fvm flutter test examples/kanban_board
```
