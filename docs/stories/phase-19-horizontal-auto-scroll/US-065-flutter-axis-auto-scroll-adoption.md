# US-065 Flutter Axis-Aware Auto-Scroll Adoption

## Status

implemented

## Lane

normal

## Product Contract

`dnd_kit_flutter` adopts the axis-aware shared auto-scroll contract by exposing
axis selection on `DndAutoScroll` and `DndAutoScrollController`, while keeping
vertical behavior as the default. Horizontal Flutter scrollables can then use
the same shared core math added in `US-064`. The Kanban example also stops
carrying its app-owned `HorizontalBoardAutoScroll` helper and uses the library
surface directly. Jaspr remains out of scope. Implements ADR 0020.

## Relevant Product Docs

- `docs/product/release-roadmap.md`
- `docs/product/package-architecture.md`
- `docs/product/api-principles.md`
- `docs/decisions/0020-axis-aware-auto-scroll.md`
- `docs/stories/phase-19-horizontal-auto-scroll/README.md`
- `packages/dnd_kit_flutter/lib/src/widgets/auto_scroll.dart`
- `packages/dnd_kit_flutter/test/src/widgets/auto_scroll_test.dart`
- `examples/kanban_board/lib/main.dart`

## Acceptance Criteria

- `DndAutoScrollController` accepts an axis selector and forwards it to the
  shared `dndAutoScrollVelocity(...)` math.
- `DndAutoScroll` exposes the same axis selector, defaults to vertical, and
  preserves current vertical behavior for existing call sites.
- Flutter widget tests cover horizontal trailing-edge scroll, horizontal
  leading-edge scroll, descendant-scrollable lookup on a horizontal list, and
  horizontal extent clamping in addition to the existing vertical tests.
- Nested opposite-axis scrollables do not steal an explicit horizontal
  `DndAutoScroll.scrollController`, so the Kanban board remains horizontally
  auto-scrollable while column lists still own their vertical auto-scroll.
- The Kanban example replaces its former app-owned horizontal helper with
  `DndAutoScroll(axis: DndScrollAxis.horizontal, ...)` in
  `examples/kanban_board/lib/main.dart`.
- No Jaspr files change in this story.

## Design Notes

- Commands:
  `fvm flutter test packages/dnd_kit_flutter`
  `fvm dart analyze packages/dnd_kit_flutter`
  `cd examples/kanban_board && fvm flutter test test/widget_test.dart`
  `cd examples/kanban_board && dart analyze`
- Queries:
  `scripts/bin/harness-cli query matrix`
  `rg -n "DndAutoScroll|DndScrollAxis|HorizontalBoardAutoScroll" packages/dnd_kit_flutter examples/kanban_board`
- API:
  `DndAutoScroll`
  `DndAutoScrollController`
  `DndScrollAxis`
- Domain rules:
  Flutter continues to own viewport measurement and `ScrollPosition` execution.
  This story only adopts the axis-aware shared math already chosen in core.
- UI surfaces:
  Flutter adapter scrollables and the Kanban example's horizontal board lane.

## Validation

When updating durable proof status, use numeric booleans:
`scripts/bin/harness-cli story update --id US-065 --unit 1 --integration 1 --e2e 0 --platform 1`.

| Layer | Expected proof |
| --- | --- |
| Unit | `packages/dnd_kit_flutter/test/src/widgets/auto_scroll_test.dart` covers horizontal trailing/leading/descendant/clamp behavior while preserving the vertical suite. |
| Integration | `fvm flutter test packages/dnd_kit_flutter` passes. |
| E2E | Not required in this Flutter adapter slice. |
| Platform | `fvm dart analyze packages/dnd_kit_flutter` and `cd examples/kanban_board && dart analyze` pass. |
| Release | `cd examples/kanban_board && fvm flutter test test/widget_test.dart` passes and `packages/dnd_kit_flutter/CHANGELOG.md` records the unreleased horizontal adoption. |

## Harness Delta

No Harness process change expected. This is the Flutter follow-up to the core
contract work in `US-064`.

## Evidence

- Created 2026-06-18 immediately after `US-064` landed, to adopt the new
  axis-aware core contract in the Flutter execution layer before moving to
  Jaspr.
- Implemented 2026-06-18 in `packages/dnd_kit_flutter` and the Kanban example:
  - `DndAutoScrollController` now accepts an axis selector, forwards it into
    the shared `dndAutoScrollVelocity(...)` math, and preserves vertical as the
    default.
  - `DndAutoScroll` now mirrors that axis selector, updates its controller when
    the widget changes, and keeps existing vertical call sites source
    compatible.
  - Flutter widget coverage now includes horizontal trailing-edge, leading-edge,
    descendant-scrollable lookup, extent clamping behavior, and a regression
    case for nested opposite-axis scrollables alongside the existing vertical
    suite.
  - The Kanban board no longer carries a separate horizontal auto-scroll helper;
    `examples/kanban_board/lib/main.dart` now uses
    `DndAutoScroll(axis: DndScrollAxis.horizontal, ...)` directly.
- Proof captured 2026-06-18:
  - `fvm flutter test packages/dnd_kit_flutter` passed with 101 tests.
  - `fvm dart analyze packages/dnd_kit_flutter` returned no issues.
  - `cd examples/kanban_board && dart analyze` returned no issues.
  - `cd examples/kanban_board && fvm flutter test test/widget_test.dart`
    passed with 5 tests.
  - Root-level `fvm flutter test examples/kanban_board` hit a Flutter tool
    cleanup crash in `build/native_assets`, so release proof uses the stable
    example-local command above instead of treating that tool issue as a code
    failure.
