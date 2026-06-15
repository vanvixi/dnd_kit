# 0016 Jaspr Adapter Scope, Runtime Model, And Browser Baseline

Date: 2026-06-15

## Status

Accepted

## Context

Phase 14 starts the `dnd_kit_jaspr` adapter on top of the shared `DndRuntime`
(ADR 0015). Before building components, `SPEC_JASPR.md` leaves four open
questions that shape the package: where the shared runtime lives (§11 Q1), the
browser/version baseline (Q2), keyboard sortable parity (Q3), and whether the
first release ships sortable presets (Q4). The runtime model (§6.1) and SSR
posture also need a durable decision so every later story builds consistently.

## Decision

1. **Custom pointer runtime, not native HTML DnD.** `dnd_kit_jaspr` normalizes
   browser pointer/mouse/touch/keyboard input into the shared
   `DndSensorActivationEvent` and `DndRuntime` updates (SPEC_JASPR §6.1). The
   native HTML Drag-and-Drop API is not used.

2. **Shared runtime stays in `dnd_kit_core`.** No separate pure-Dart package yet
   (SPEC_JASPR Q1); revisit only if the core surface grows unwieldy.

3. **SSR-safe library posture.** `dnd_kit_jaspr` is a library with no Jaspr
   `mode` and no entrypoints. Shared code accesses the DOM through
   `package:universal_web` guarded by `kIsWeb` and must not import
   `dart:js_interop` / `package:web` at top level, so it is importable from a
   server entrypoint. Interactive drag wiring runs in the browser under
   `@client` hydration in consuming apps; the library does not impose the
   hydration boundary.

4. **Generic drag/drop first, sortable later** (SPEC_JASPR Q4). Phase B/C ship
   the generic foundation (scope, controller, draggable, droppable, handle,
   sensors, measuring, collision, overlay, modifiers, keyboard/a11y,
   auto-scroll). Sortable presets (vertical/horizontal/grid) come in Phase D and
   reuse the already-shared sortable math.

5. **Browser baseline: evergreen with Pointer Events Level 2.** Target current
   Chromium/Edge, Firefox, and Safari that support Pointer Events L2 and
   `Element.getBoundingClientRect`. Jaspr `^0.23.0`. No legacy/IE support.

6. **Keyboard sortable parity is best-effort** (SPEC_JASPR Q3). Keyboard drag
   flows follow web accessibility norms rather than copying Flutter semantics
   literally; exact parity is decided per strategy in Phase D.

## Alternatives Considered

1. Native HTML DnD API — rejected (§6.1: inconsistent across browsers/inputs,
   tied to `dataTransfer`, reduces shared logic).
2. Ship sortable in the first release — rejected; prove the generic foundation
   first to avoid baking in a weak base.
3. Make the scope a forced `@client` component — rejected; the host app owns the
   hydration boundary.

## Consequences

Positive:

- Maximum reuse of the shared engine; adapter code limited to browser wiring.
- One portable callback/contract surface across Flutter and Jaspr.
- Package is safe to import in any Jaspr render mode.

Tradeoffs:

- A custom pointer runtime means the adapter owns pointer capture, touch-action,
  and scroll interaction details instead of delegating to the browser.
- `universal_web` + `kIsWeb` discipline must be enforced in every shared file.

## Follow-Up

- Implement the foundation under US-048; sequence US-049+ per
  `docs/stories/phase-14-jaspr-foundation/README.md`.
- Decide the deferred `DndPointerSensor` sharing during US-049.
