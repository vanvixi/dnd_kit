# US-004 Core Drag State And Session

## Status

implemented

## Lane

normal

## Product Contract

`dnd_kit_core` must expose a pure Dart drag lifecycle model that later
controllers, sensors, collision detectors, modifiers, and Flutter adapters can
share without depending on Flutter or user-owned data.

## Relevant Product Docs

- `docs/product/overview.md`
- `docs/product/package-architecture.md`
- `docs/product/api-principles.md`
- `docs/product/release-roadmap.md`

## Acceptance Criteria

- `dnd_kit_core` exports sealed drag states for idle, pending, dragging,
  dropping, and cancelled phases.
- Valid transitions are modeled explicitly:
  `idle -> pending`, `pending -> dragging`, `pending -> cancelled`,
  `dragging -> dropping`, `dragging -> cancelled`, `dropping -> idle`, and
  `cancelled -> idle`.
- Invalid transitions are rejected in debug mode.
- `DndDragSession` tracks the active draggable id, initial pointer, current
  pointer, input kind, delta, and transform without Flutter types.
- State and session objects are immutable value objects with predictable
  equality, hash codes, and readable `toString` output.
- Unit tests cover valid transitions, invalid transitions, and session movement
  helpers.

## Design Notes

- Commands: `fvm dart format .`, `fvm dart analyze`,
  `fvm dart test packages/dnd_kit_core`, and
  `scripts/bin/harness-cli story verify US-004`.
- Queries: `scripts/bin/harness-cli query matrix`.
- API: pure Dart drag lifecycle and drag session only; no controller, registry,
  collision detector, modifier runtime, sensor implementation, or Flutter
  widget behavior in this story.
- Tables: none.
- Domain rules: applications still own user data and collection mutation.
- UI surfaces: none.

## Validation

When updating durable proof status, use numeric booleans:
`scripts/bin/harness-cli story update --id US-004 --unit 1 --integration 0 --e2e 0 --platform 0`.

| Layer | Expected proof |
| --- | --- |
| Unit | `fvm dart test packages/dnd_kit_core` passes. |
| Integration | Not required; this story introduces only one package's pure Dart state model. |
| E2E | Not required; no user-facing UI exists. |
| Platform | Not required; no Flutter/platform code exists. |
| Release | `fvm dart analyze` passes from the repository root. |

## Harness Delta

- Adds the second Phase 1 story packet and durable matrix row.

## Evidence

- `fvm dart format .` completed with no changes needed.
- `fvm dart analyze` passed with no issues.
- `fvm dart test packages/dnd_kit_core` passed with 24 tests.
- `scripts/bin/harness-cli story verify US-004` passed with
  `fvm dart test packages/dnd_kit_core`.
