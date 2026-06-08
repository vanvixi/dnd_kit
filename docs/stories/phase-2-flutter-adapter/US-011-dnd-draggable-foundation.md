# US-011 DndDraggable Foundation

## Status

implemented

## Lane

normal

## Product Contract

`dnd_kit_flutter` must expose a first `DndDraggable` widget that lets Flutter
applications register draggable metadata and start a controller-backed drag
lifecycle through basic pointer gestures while keeping application data outside
the library.

## Relevant Product Docs

- `docs/product/overview.md`
- `docs/product/package-architecture.md`
- `docs/product/api-principles.md`
- `docs/product/release-roadmap.md`

## Acceptance Criteria

- `dnd_kit_flutter` exports `DndDraggable`.
- `DndDraggable` requires a stable `DndId`, a child, and a surrounding
  `DndScope`.
- `DndDraggable` registers a `DndDraggableRegistration` with the nearest
  controller registry and unregisters it when disposed.
- Updating id, disabled state, data, or controller scope keeps registry metadata
  current without leaking stale entries.
- Disabled draggables remain registered as disabled metadata but do not start a
  drag.
- Basic pan gestures call controller begin, start, move, end, cancel, and reset
  methods using core `DndPoint`, `DndInputKind`, and drag event models.
- Optional callbacks expose core `DndDragStartEvent`, `DndDragMoveEvent`,
  `DndDragEndEvent`, and `DndDragCancelEvent` values.
- Widget tests cover registration, registry updates, disabled behavior,
  lifecycle callbacks, and unregistering on disposal.

## Design Notes

- Commands: `fvm dart format .`, `fvm flutter test packages/dnd_kit_flutter`,
  `fvm dart analyze`, and `scripts/bin/harness-cli story verify US-011`.
- Queries: `scripts/bin/harness-cli query matrix`.
- API: Flutter adapter widget foundation only.
- Tables: none.
- Domain rules: applications own user data and collection mutation.
- UI surfaces: `DndDraggable` wraps a child and uses basic pan gestures.

## Validation

When updating durable proof status, use numeric booleans:
`scripts/bin/harness-cli story update --id US-011 --unit 1 --integration 1 --e2e 0 --platform 0`.

| Layer | Expected proof |
| --- | --- |
| Unit | `fvm flutter test packages/dnd_kit_flutter` passes. |
| Integration | Widget tests prove registration and gesture lifecycle behavior through `DndScope` and `DndController`. |
| E2E | Not required; no complete drag/drop flow exists yet. |
| Platform | Not required; no platform-specific sensor behavior exists yet. |
| Release | `fvm dart analyze` passes from the repository root. |

## Harness Delta

- Adds the second Phase 2 story packet and durable matrix row.

## Evidence

- `fvm dart format .` passed with 26 Dart files already formatted.
- `fvm flutter test packages/dnd_kit_flutter` passed with 14 tests.
- `fvm dart analyze` passed with no issues.
- `scripts/bin/harness-cli story verify US-011` passed.
