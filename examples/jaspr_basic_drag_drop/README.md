# Jaspr Basic Drag Drop Example

Runnable browser example for `dnd_kit_jaspr`.

It demonstrates:

- `DndScope` controller ownership;
- `DndDraggable`, `DndDroppable`, and `DndDragHandle`;
- `DndDragOverlay` for the active drag visual;
- application-owned drop state;
- shared-runtime modifiers (`restrictToHorizontalAxis` + `snapToGrid`).

Current status: this example is the local app used for the US-053 browser-proof
work. Shared modifiers are covered by browser tests, and the browser-driven
proof now uses this app to verify real drag state and modifier behavior.

## Run

```bash
cd examples/jaspr_basic_drag_drop
~/.pub-cache/bin/jaspr serve
```

The development server defaults to `http://localhost:8080`.

## Build

```bash
cd examples/jaspr_basic_drag_drop
~/.pub-cache/bin/jaspr build
```
