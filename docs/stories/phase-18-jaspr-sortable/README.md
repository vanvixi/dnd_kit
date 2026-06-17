# Phase 18 — Jaspr Sortable Preset

This phase closes the largest feature gap between the two peer adapters by giving
`dnd_kit_jaspr` a sortable preset, reusing the framework-neutral reorder engine
that already powers the Flutter adapter.

## Why now

After US-061 the Jaspr adapter is a workspace member at full diagnostics/keyboard/
accessibility parity, but it had no first-class reorder surface — only free-form
`DndDraggable`/`DndDroppable`. The reorder math (`SortableStrategies`,
`SortableMoveDetails`, `SortableStrategyInput`, multi-container helpers) already
lives in `package:dnd_kit` and is re-exported by `dnd_kit_jaspr`, so only the
component layer that drives it was missing.

## Delivery Sequence

| Story | Scope | Decision |
| --- | --- | --- |
| **US-062** | Add Jaspr `SortableScope` + `SortableItem` over the shared engine; export them; bump `dnd_kit_jaspr` to `0.3.0-dev.1` | ADR 0019 |

## Validation Ladder

- Engine and Flutter packages are untouched (no version change).
- `fvm dart run melos run validate` passes — format, analyze all members, and the
  new Jaspr sortable unit/component tests under `dart test packages/dnd_kit_jaspr`.
- `fvm dart pub publish --dry-run` for `packages/dnd_kit_jaspr` passes with the
  `0.3.0-dev.1` metadata.
