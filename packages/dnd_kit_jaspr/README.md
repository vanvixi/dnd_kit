# dnd_kit_jaspr

Jaspr (web) adapter for the [`dnd_kit`](https://github.com/vanvixi/dnd_kit)
drag-and-drop family.

`dnd_kit_jaspr` is built on the shared `dnd_kit_core` engine, so Jaspr and
Flutter behave as peer adapters over one drag runtime — the same domain model,
drag lifecycle, collision logic, modifiers, and sortable math. It depends only
on `dnd_kit_core` and `jaspr` (no Flutter).

> Status: early development. This release provides `DndScope`,
> `DndController`, `DndDraggable`, `DndDroppable`, `DndDragHandle`, and
> `DndDragOverlay` over the shared runtime. Shared modifiers are exercised in
> browser tests, and `examples/jaspr_basic_drag_drop` is the runnable app used
> for the current browser-proof work. Sortable presets are still in progress.
> See `SPEC_JASPR.md` and
> `docs/stories/phase-14-jaspr-foundation/`.

## Usage

```dart
import 'package:dnd_kit_jaspr/dnd_kit_jaspr.dart';

// Wrap an interactive subtree in a DndScope; descendants read the controller
// via DndScope.of(context).
DndScope(
  child: myDragDropUi,
);
```

Applications own their item, board, or document data. `dnd_kit_jaspr` reports
drag/drop intent so app code updates its own state.

## Example

See `examples/jaspr_basic_drag_drop` for a runnable Jaspr browser app that
wires `DndScope`, `DndDraggable`, `DndDroppable`, `DndDragHandle`,
`DndDragOverlay`, and shared-runtime modifiers into one small flow.
