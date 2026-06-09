# US-024 Flutter Auto-Scroll Foundation

## Status

implemented

## Lane

normal

## Product Contract

`dnd_kit_flutter` provides a Flutter adapter auto-scroll surface that scrolls a
nearby `Scrollable` while an active drag is held near its viewport edges. The
behavior is opt-in, scoped to Flutter adapter widgets, and does not mutate
application-owned drag/drop data.

## Relevant Product Docs

- `docs/product/overview.md`
- `docs/product/package-architecture.md`
- `docs/product/api-principles.md`
- `docs/product/release-roadmap.md`

## Acceptance Criteria

- A Flutter widget API enables auto-scroll for a subtree using the nearest
  `DndScope` controller by default and an optional explicit `ScrollController`
  when applications already own one.
- Auto-scroll starts when the active drag position enters a configurable edge
  threshold of a vertical `Scrollable`.
- Auto-scroll direction and velocity respond to whether the drag position is
  near the leading or trailing edge.
- Auto-scroll stops when the drag leaves the edge zone, when dragging ends, when
  the widget is disabled, or when the scrollable can no longer scroll in that
  direction.
- Existing drag, overlay, visual state, and controller APIs remain
  source-compatible.

## Design Notes

- Commands:
  - `fvm dart format .`
  - `fvm flutter test packages/dnd_kit_flutter`
  - `fvm dart analyze`
- Queries:
  - `scripts/bin/harness-cli query matrix`
- API:
  - `DndAutoScroll`
  - `DndAutoScrollController`
  - `DndAutoScrollOptions`
- Tables:
  - Harness `story` proof row for `US-024`.
- Domain rules:
  - User data remains external; auto-scroll changes viewport offset only.
  - Auto-scroll belongs to `dnd_kit_flutter`, not `dnd_kit_core`.
  - The first slice supports vertical scrollables; horizontal and nested
    scrollable policies remain future work.
- UI surfaces:
  - Flutter adapter widget subtree containing a `Scrollable`.

## Validation

When updating durable proof status, use numeric booleans:
`scripts/bin/harness-cli story update --id US-024 --unit 1 --integration 1 --e2e 0 --platform 0`.

| Layer | Expected proof |
| --- | --- |
| Unit | Widget tests prove auto-scroll starts near trailing and leading vertical edges, supports explicit and descendant scroll targets, stops when disabled or drag ends, and does not exceed scroll extents. |
| Integration | `fvm flutter test packages/dnd_kit_flutter` passes. |
| E2E | Not required for this adapter API slice. |
| Platform | Not required for this adapter API slice. |
| Release | `fvm dart analyze` and `fvm dart format .` pass. |

## Harness Delta

None expected.

## Evidence

- `fvm dart format .` passed.
- `fvm flutter test packages/dnd_kit_flutter/test/src/widgets/auto_scroll_test.dart`
  passed with 6 auto-scroll widget tests.
- `fvm flutter test packages/dnd_kit_flutter` passed with 67 Flutter adapter
  tests, including auto-scroll coverage.
- `fvm dart analyze` passed with no issues.
- `scripts/bin/harness-cli story verify US-024` passed.
