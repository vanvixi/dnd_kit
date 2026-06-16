# Phase 14 — Jaspr Adapter Foundation

This phase delivers `dnd_kit_jaspr`, a Jaspr/browser adapter built on the shared
`DndRuntime` extracted in Phase 13 (US-047, ADR 0015). Source spec:
`SPEC_JASPR.md`. Architecture decision: `docs/decisions/0016-jaspr-adapter-scope-and-runtime-model.md`.

## Principle

`dnd_kit_jaspr` is a peer adapter over the same engine as `dnd_kit_flutter`. It
adds only browser-specific wiring — components, pointer input, DOM measuring,
overlay, scroll execution, and accessibility — and reuses the shared runtime,
collision, modifiers, measuring contract, sortable math, and auto-scroll math
from `dnd_kit_core`. No second drag engine.

## Delivery Sequence

This mirrors how the Flutter adapter was built (US-010 → US-013 …).

| Story | Scope | SPEC |
| --- | --- | --- |
| **US-048** | Package scaffold + `DndScope` + `DndController` on `DndRuntime` (walking skeleton) | §3.3, §5, §9 Phase B |
| US-049 | `DndDraggable` + pointer sensor activation + DOM measuring | §5.1, §6.2 |
| US-050 | `DndDroppable` + collision runtime wiring | §5.1 |
| US-051 | `DndDragHandle` + mouse/touch/keyboard activation kinds | §5.1, §7 |
| US-052 | `DndDragOverlay` via top-level/portal DOM layer | §6.3 |
| US-053 | Modifiers wiring + `jaspr_basic_drag_drop` example + browser proof | §5.1, §8.2 |
Phase C (hardening: keyboard/a11y, auto-scroll execution, diagnostics alignment)
and Phase D (sortable presets: vertical/horizontal/grid) follow in later phases.

## Validation Ladder

- Shared contract proof: pure-Dart `dart test` reusing `dnd_kit_core` runtime
  tests (state, collision, modifiers, measuring, sortable math).
- Adapter proof: `jaspr_test` component tests + browser integration via the
  `chrome-devtools` MCP (pointer drag, overlay, collision-while-scrolling).
- Cross-adapter parity: portable scenarios behaving the same in Flutter and
  Jaspr (drag start/cancel, drop resolution, modifier transform).
