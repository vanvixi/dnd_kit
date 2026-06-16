# Exec Plan

## Goal

Give the Jaspr adapter a working drag source (`DndDraggable`) built on a shared
pointer sensor, while keeping one activation state machine across Flutter and
Jaspr.

## Scope

In scope:

- Move `DndPointerSensor` + callback typedefs to `dnd_kit_core` on `DndRuntime`.
- Add `DndController.runtime` to the Flutter and Jaspr controllers.
- Flutter: re-export `DndPointerSensor`; update its draggable to pass
  `runtime: controller.runtime`; move the sensor test to core; CHANGELOG note.
- Jaspr: `DndDraggable` (registration lifecycle, DOM measuring, pointer-capture
  sensor wiring, transform follow); `universal_web` dependency.
- Tests: core pointer-sensor contract tests; jaspr_test draggable registration.

Out of scope:

- Droppable/collision, drag handle, overlay, keyboard, auto-scroll, sortable.
- Real in-browser drag proof (US-053).

## Risk Classification

Risk flags:

- Public contracts (Jaspr gains public components; Flutter `DndPointerSensor`
  constructor changes `controller:` → `runtime:`).
- Existing behavior (Flutter draggable rewired to the shared sensor).
- Cross-platform (browser DOM + SSR posture).

Hard gates: none. High-risk lane because it changes a published Flutter API and
adds browser components.

## Work Phases

1. Discovery — Flutter draggable/sensor structure + Jaspr/web DOM APIs reviewed
   (pointer capture chosen over document listeners for SSR safety). Done.
2. Design — see `design.md`.
3. Validation planning — see `validation.md`.
4. Implementation — sensor move (core + Flutter) → Jaspr `DndDraggable`.
5. Verification — analyze + test across core, flutter, jaspr.
6. Harness update — proof + evidence; CHANGELOG.

## Stop Conditions

Pause for human confirmation if:

- A browser API forces `dart:js_interop` into SSR-imported code (would break the
  ADR 0016 posture).
- The shared sensor cannot drive Flutter without changing widget behavior.
