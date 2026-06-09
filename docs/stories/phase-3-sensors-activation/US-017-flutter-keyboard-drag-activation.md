# US-017 Flutter Keyboard Drag Activation

## Status

implemented

## Lane

normal

## Product Contract

`dnd_kit_flutter` must let keyboard users focus a draggable, pick it up, move it
with arrow keys, drop it, or cancel it without requiring pointer input.

## Relevant Product Docs

- `docs/product/overview.md`
- `docs/product/package-architecture.md`
- `docs/product/api-principles.md`
- `docs/product/release-roadmap.md`

## Acceptance Criteria

- Space and Enter can pick up a focused draggable.
- Arrow keys move the active keyboard drag session by a configurable step.
- Escape cancels an active keyboard drag.
- Space and Enter drop an active keyboard drag.
- Keyboard activation reports `DndInputKind.keyboard`.
- A semantics hint exists for keyboard dragging.
- Widget tests cover keyboard pick-up, movement, drop, cancel, disabled state,
  and the no-droppable case.

## Design Notes

- Commands: `fvm dart format .`, `fvm flutter test packages/dnd_kit_flutter`,
  `fvm dart analyze`, and `scripts/bin/harness-cli story verify US-017`.
- Queries: `scripts/bin/harness-cli query matrix`.
- API: add a small `keyboardDragStep` option on `DndDraggable` while keeping
  pointer, long-press, and handle behavior unchanged.
- Tables: none.
- Domain rules: applications still own user data and collection mutation.
- UI surfaces: keyboard activation only; overlays, auto-scroll, sortable
  keyboard coordinates, and dedicated examples remain out of scope.

## Validation

When updating durable proof status, use numeric booleans:
`scripts/bin/harness-cli story update --id US-017 --unit 1 --integration 1 --e2e 0 --platform 0`.

| Layer | Expected proof |
| --- | --- |
| Unit | `fvm flutter test packages/dnd_kit_flutter` passes. |
| Integration | Widget tests prove keyboard flow through `DndScope`, `DndController`, and `DndDraggable`. |
| E2E | Not required; no full example app flow changes in this story. |
| Platform | Not required; keyboard activation uses Flutter widget tests only. |
| Release | `fvm dart analyze` passes from the repository root. |

## Harness Delta

- Adds the fourth Phase 3 story packet and durable matrix row.

## Evidence

- `fvm dart format .` passed.
- `fvm flutter test packages/dnd_kit_flutter` passed with 41 tests, including
  keyboard pick-up, movement, drop, cancel, disabled state, no-droppable, and
  semantics hint coverage.
- `fvm dart analyze` passed with no issues.
- `scripts/bin/harness-cli story verify US-017` passed.
