# Jaspr Basic Drag Drop Example

Runnable browser example for `dnd_kit_jaspr`.

It demonstrates:

- `DndScope` controller ownership;
- `DndDraggable`, `DndDroppable`, and `DndDragHandle`;
- `DndDragOverlay` for the active drag visual;
- application-owned drop state;
- free-form drag movement driven by the shared runtime.

Current status: this example is the local app used for the US-053 browser-proof
work. Browser tests still cover shared modifiers, and the browser-driven proof
uses this app to verify real drag state, handle activation, and lane updates.

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
