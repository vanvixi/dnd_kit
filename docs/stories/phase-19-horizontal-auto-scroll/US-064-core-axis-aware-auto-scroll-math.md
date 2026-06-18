# US-064 Core Axis-Aware Auto-Scroll Math

## Status

implemented

## Lane

normal

## Product Contract

`dnd_kit` extends its shared auto-scroll contract with an additive axis
selector so `dndAutoScrollVelocity(...)` can compute either vertical or
horizontal edge velocity while preserving current vertical behavior by default.
This story changes only the core package and its tests. Flutter and Jaspr do
not adopt the new axis yet; they remain vertical-only until later Phase 19
stories apply the shared contract in their execution layers. Implements ADR
0020.

## Relevant Product Docs

- `docs/product/release-roadmap.md`
- `docs/product/package-architecture.md`
- `docs/product/api-principles.md`
- `docs/decisions/0020-axis-aware-auto-scroll.md`
- `docs/stories/phase-19-horizontal-auto-scroll/README.md`
- `packages/dnd_kit/lib/src/auto_scroll.dart`
- `packages/dnd_kit/test/src/auto_scroll_test.dart`

## Acceptance Criteria

- `dnd_kit` exports a new additive enum for auto-scroll axis selection
  (`vertical`, `horizontal`).
- `dndAutoScrollVelocity(...)` accepts an optional axis selector that defaults
  to vertical, so existing call sites and current vertical behavior remain
  source-compatible.
- Vertical math stays unchanged for the default axis.
- Horizontal math uses the same threshold and velocity curve against the x-axis
  and viewport width, still returning `0` when the pointer is outside the
  viewport or the scroll extent is already clamped.
- Core unit tests cover horizontal neutral, leading, trailing, clamp, and
  out-of-bounds behavior in addition to the existing vertical cases.
- No Flutter or Jaspr execution-layer files change in this story.

## Design Notes

- Commands:
  `fvm dart test packages/dnd_kit`
  `fvm dart analyze packages/dnd_kit`
- Queries:
  `scripts/bin/harness-cli query matrix`
  `rg -n "dndAutoScrollVelocity|DndAutoScrollOptions|DndScrollAxis" packages/dnd_kit`
- API:
  `DndScrollAxis`
  `dndAutoScrollVelocity`
  `DndAutoScrollOptions`
- Domain rules:
  The shared curve stays single-source-of-truth in `dnd_kit`. This story adds
  a selector, not a second helper with divergent math. Adapters continue to own
  viewport measurement and scroll execution.
- UI surfaces:
  None directly. This is core contract work only.

## Validation

When updating durable proof status, use numeric booleans:
`scripts/bin/harness-cli story update --id US-064 --unit 1 --integration 0 --e2e 0 --platform 1`.

| Layer | Expected proof |
| --- | --- |
| Unit | `packages/dnd_kit/test/src/auto_scroll_test.dart` covers vertical compatibility plus horizontal neutral/leading/trailing/clamp/out-of-bounds cases. |
| Integration | Not required in this core-only slice. |
| E2E | Not required in this core-only slice. |
| Platform | `fvm dart test packages/dnd_kit` and `fvm dart analyze packages/dnd_kit` pass. |
| Release | `packages/dnd_kit/CHANGELOG.md` mentions the new axis-aware shared math surface. |

## Harness Delta

No Harness process change expected. This is the first implementation slice that
follows the design chosen in ADR 0020.

## Evidence

- Created 2026-06-18 immediately after `US-063` closed and ADR 0020 was
  accepted, to land the shared core contract before adapter adoption.
- Implemented 2026-06-18 in `packages/dnd_kit` only:
  - added `DndScrollAxis` with `vertical` and `horizontal`;
  - extended `dndAutoScrollVelocity(...)` with an additive `axis` parameter
    defaulting to `vertical`;
  - preserved the existing viewport bounds check and vertical behavior while
    reusing the same threshold/velocity curve on the horizontal axis;
  - expanded `packages/dnd_kit/test/src/auto_scroll_test.dart` with horizontal
    neutral/leading/trailing/clamp/out-of-bounds coverage.
- Proof:
  - `fvm dart test packages/dnd_kit` -> 119 passed.
  - `fvm dart analyze packages/dnd_kit` -> No issues found.
- Release-facing docs:
  - `packages/dnd_kit/CHANGELOG.md` now records the unreleased axis-aware
    shared auto-scroll math surface.
