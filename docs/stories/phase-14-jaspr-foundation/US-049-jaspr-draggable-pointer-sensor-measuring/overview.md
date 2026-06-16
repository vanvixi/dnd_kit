# Overview

## Current Behavior

After US-048 the Jaspr adapter has only `DndScope` + `DndController`. There is no
drag source. The pointer-activation state machine (`DndPointerSensor`) lives in
`dnd_kit_flutter` and is driven by a Flutter `DndController`, so it cannot be
reused by Jaspr.

## Target Behavior

- `DndPointerSensor` (and its callback typedefs) move to `dnd_kit_core`, driven
  by the shared `DndRuntime`. Both adapter controllers expose
  `DndController.runtime`. Flutter re-exports `DndPointerSensor` and constructs
  it with `runtime: controller.runtime`; its widget behavior is unchanged.
- A Jaspr `DndDraggable` component:
  - registers a stable `DndId` with the enclosing scope's controller (with owner
    semantics) and unregisters on dispose;
  - measures its DOM element via `getBoundingClientRect` → `DndRect`;
  - starts the shared `DndPointerSensor` from browser pointer events, using
    pointer capture + element-level `pointerdown/move/up/cancel` wired through
    Jaspr's `events:` map (no document listeners, no `dart:js_interop`);
  - follows the pointer during an active drag via a CSS transform.
- All DOM access is guarded by `kIsWeb`, so the component stays importable in any
  Jaspr render mode (SSR-safe per ADR 0016).

## Affected Users

- Jaspr app developers (gain a working drag source).
- Existing `dnd_kit_flutter` users (one breaking change to the internal
  `DndPointerSensor` constructor: `controller:` → `runtime:`).

## Affected Product Docs

- `SPEC_JASPR.md` §4.3, §5.1, §6.2
- `docs/ARCHITECTURE.md`
- `docs/decisions/0016-jaspr-adapter-scope-and-runtime-model.md`

## Non-Goals

- `DndDroppable` + collision wiring (US-050).
- `DndDragHandle` + keyboard/mouse/touch specialization (US-051).
- Drag overlay / portal layer (US-052); the element transform here is interim.
- Real in-browser drag proof via chrome-devtools (US-053, with the example app).
- Auto-scroll execution and sortable presets.
