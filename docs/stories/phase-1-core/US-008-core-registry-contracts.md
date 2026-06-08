# US-008 Core Registry Contracts

## Status

implemented

## Lane

normal

## Product Contract

`dnd_kit_core` must expose pure Dart registry contracts for draggable and
droppable entries so later Flutter controllers, measuring runtimes, sensors,
and sortable presets can share stable ID registration behavior without
depending on Flutter APIs.

## Relevant Product Docs

- `docs/product/overview.md`
- `docs/product/package-architecture.md`
- `docs/product/api-principles.md`
- `docs/product/release-roadmap.md`

## Acceptance Criteria

- `dnd_kit_core` exports draggable and droppable registration value objects.
- Registration value objects compare by value and carry stable IDs without
  Flutter geometry or widget types.
- A core registry can register, update, unregister, and query draggable and
  droppable entries by `DndId`.
- Duplicate draggable or droppable IDs are rejected in debug mode.
- Registry snapshots expose immutable draggable and droppable maps.
- Unit tests cover value behavior, duplicate diagnostics, immutable snapshots,
  and register/update/unregister flows.

## Design Notes

- Commands: `fvm dart format .`, `fvm dart analyze`,
  `fvm dart test packages/dnd_kit_core`, and
  `scripts/bin/harness-cli story verify US-008`.
- Queries: `scripts/bin/harness-cli query matrix`.
- API: pure Dart registry contracts only; no Flutter widget, render object,
  controller lifecycle, measuring, sensor runtime, overlay, or sortable
  mutation behavior in this story.
- Tables: none.
- Domain rules: applications own user data; registry entries carry only stable
  library metadata and optional opaque application data.
- UI surfaces: none.

## Validation

When updating durable proof status, use numeric booleans:
`scripts/bin/harness-cli story update --id US-008 --unit 1 --integration 0 --e2e 0 --platform 0`.

| Layer | Expected proof |
| --- | --- |
| Unit | `fvm dart test packages/dnd_kit_core` passes. |
| Integration | Not required; this story introduces only one package's pure Dart registry model. |
| E2E | Not required; no user-facing UI exists. |
| Platform | Not required; no Flutter/platform code exists. |
| Release | `fvm dart analyze` passes from the repository root. |

## Harness Delta

- Adds the sixth Phase 1 story packet and durable matrix row.

## Evidence

- `fvm dart format .` completed with no changes needed after implementation.
- `fvm dart analyze` passed with no issues.
- `fvm dart test packages/dnd_kit_core` passed with 63 tests.
- `scripts/bin/harness-cli story verify US-008` passed with
  `fvm dart test packages/dnd_kit_core`.
