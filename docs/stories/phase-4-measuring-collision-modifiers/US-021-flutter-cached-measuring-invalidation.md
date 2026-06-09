# US-021 Flutter Cached Measuring Invalidation

## Status

implemented

## Lane

normal

## Product Contract

`dnd_kit_flutter` must keep adapter-owned measured rectangles cached during an
active drag while invalidating and refreshing stale measurements at predictable
layout boundaries, so collision detection and modifiers use current geometry
without remeasuring every pointer or keyboard movement.

## Relevant Product Docs

- `docs/product/overview.md`
- `docs/product/package-architecture.md`
- `docs/product/api-principles.md`
- `docs/product/release-roadmap.md`

## Acceptance Criteria

- `DndMeasuringRegistry` exposes enough cache state to distinguish known,
  missing, dirty, and removed draggable or droppable measurements.
- `DndDraggable` and `DndDroppable` invalidate cached measurements when mounted,
  updated with a different `DndId`, disabled/enabled, laid out after a size or
  position change, or unmounted.
- Active drag movement reuses clean cached measurements and refreshes only dirty
  measurements before collision detection and modifier input are calculated.
- Keyboard and pointer drag paths share the same cached measuring refresh path.
- Disabled droppables remain registered but are excluded from collision input
  even if a cached rectangle exists.
- Unmounted widgets remove their cached rectangles and cannot remain as stale
  collision candidates.
- Public APIs continue to expose core geometry (`DndRect`) rather than Flutter
  geometry types.
- Existing measuring, collision, and modifier behavior remains unchanged when no
  layout invalidation occurs.
- Flutter adapter tests cover cache reuse, dirty refresh, id changes, unmount
  removal, disabled droppable filtering, and pointer and keyboard drag movement.

## Design Notes

- Commands: `fvm dart format .`, `fvm flutter test packages/dnd_kit_flutter`,
  `fvm dart analyze`, and `scripts/bin/harness-cli story verify US-021`.
- Queries: `scripts/bin/harness-cli query matrix`.
- API: prefer adapter-internal invalidation methods on `DndMeasuringRegistry`
  before adding public measuring strategy APIs.
- Tables: none.
- Domain rules: applications still own user data and collection mutation.
- UI surfaces: no overlay, auto-scroll, sortable preset, or new visual state in
  this story.
- Implementation shape: keep Flutter `BuildContext`, `RenderBox`, `Offset`,
  `Rect`, and `Size` at the adapter boundary; store only `DndRect` and cache
  metadata in controller-owned measuring state.

## Validation

When updating durable proof status, use numeric booleans:
`scripts/bin/harness-cli story update --id US-021 --unit 1 --integration 1 --e2e 0 --platform 0`.

| Layer | Expected proof |
| --- | --- |
| Unit | `fvm flutter test packages/dnd_kit_flutter` covers measuring registry cache state and invalidation behavior. |
| Integration | Widget tests prove `DndScope`, `DndDraggable`, and `DndDroppable` refresh dirty measurements before pointer and keyboard collision runtime. |
| E2E | Not required; no example app flow changes in this story. |
| Platform | Not required; cache invalidation is adapter widget behavior covered by Flutter tests. |
| Release | `fvm dart analyze` passes from the repository root. |

## Harness Delta

- Adds the next Phase 4 hardening story packet before Phase 5 overlay work.
- Resolves the stale README status friction that made the current phase unclear.

## Evidence

- `fvm dart format .` passed; 34 files checked with no formatting changes after
  final cleanup.
- `fvm flutter test packages/dnd_kit_flutter` passed with 53 tests, including
  measuring registry cache state, controller dirty refresh before collision and
  modifier runtime, draggable measurement lifecycle, droppable id-change
  removal, and disabled-droppable filtering coverage.
- `fvm dart analyze` passed with no issues.
- `scripts/bin/harness-cli story verify US-021` passed.
