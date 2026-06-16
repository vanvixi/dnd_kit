# US-056 Jaspr Auto-scroll Execution

## Status

implemented

## Lane

normal

## Product Contract

`dnd_kit_jaspr` must auto-scroll the nearest scrollable ancestor and the document
viewport while a drag is active and the pointer approaches an edge, so drags can
reach targets outside the currently visible area. The edge-threshold and velocity
math stays in `dnd_kit_core` (`dndAutoScrollVelocity`); Jaspr only adds the
browser execution layer (DOM measuring + scrolling) and must stay SSR-safe.

## Relevant Product Docs

- `docs/product/api-principles.md`
- `docs/product/package-architecture.md`
- `docs/ARCHITECTURE.md`
- `docs/decisions/0016-jaspr-adapter-scope-and-runtime-model.md`
- `SPEC_JASPR.md` (§6.4, §9 Phase C)
- `packages/dnd_kit_flutter/lib/src/widgets/auto_scroll.dart` (reference execution layer)

## Acceptance Criteria

- During an active drag, when the pointer enters the leading or trailing edge
  band of a scroll container (or the viewport), that container scrolls toward the
  pointer; scrolling stops when the pointer leaves the band, the extent is
  clamped, or the drag ends/cancels.
- Scroll velocity is computed only via the shared `dndAutoScrollVelocity` using
  viewport-local pointer, viewport size, and current scroll extents; no edge or
  speed math is reimplemented in the adapter.
- Execution is driven by a frame-paced loop (not a per-pointer-move burst) and is
  fully torn down on drag end, cancel, and component dispose — no leaked timers
  or listeners. A frame-interval `Timer` is used instead of
  `requestAnimationFrame` so the package needs no top-level `dart:js_interop`
  (SSR posture, ADR 0016).
- Collision/`overId` continues to resolve correctly against the post-scroll
  coordinates (measurements refresh so a target scrolled into view is reachable).
- The adapter remains SSR-safe: all DOM access goes through
  `package:universal_web` guarded by `kIsWeb`, with no `dart:js_interop` at top
  level; importing the package from a server entrypoint stays safe.
- If horizontal auto-scroll is supported, the axis math is added DOM-free to
  `dnd_kit_core` (extending `dndAutoScrollVelocity`/a sibling), not in the
  adapter. If horizontal is deferred, the story states so explicitly.

## Design Notes

- Commands:
  `fvm dart test packages/dnd_kit_core`
  `fvm dart test packages/dnd_kit_jaspr`
  `cd packages/dnd_kit_jaspr && fvm dart test -p chrome test/auto_scroll_browser_test.dart`
  `fvm dart analyze packages/dnd_kit_jaspr`
- Queries:
  `scripts/bin/harness-cli query matrix`
  `rg -n "dndAutoScrollVelocity|DndAutoScrollOptions|scrollTop|scrollBy|requestAnimationFrame" packages/dnd_kit_jaspr packages/dnd_kit_core`
- API:
  `dndAutoScrollVelocity`
  `DndAutoScrollOptions`
  `DndController.activeRect` / `DndController.state`
  a new Jaspr auto-scroll execution surface (e.g. `DndAutoScroll` component or a
  scope-level option) — name decided in design.
- Domain rules:
  Edge/velocity math is owned by `dnd_kit_core`; the shared `DndRuntime` stays
  the only drag engine. The adapter measures the scroll container and viewport
  and applies scroll deltas; it must not fork the velocity curve. Applications
  continue to own their data and scroll structure.
- UI surfaces:
  A scrollable Jaspr container (and/or the document viewport) under `DndScope`
  whose content scrolls while a drag pointer rests near an edge.

## Validation

When updating durable proof status, use numeric booleans:
`scripts/bin/harness-cli story update --id US-056 --unit 1 --integration 1 --e2e 0 --platform 1`.

| Layer | Expected proof |
| --- | --- |
| Unit | `dndAutoScrollVelocity` edge/clamp/velocity cases stay covered in `dnd_kit_core` (plus any new axis math added DOM-free). |
| Integration | `jaspr_test` proves the execution layer requests/stops scrolling for edge vs neutral pointer positions and tears down on drag end. |
| E2E | A Chrome browser test (`auto_scroll_browser_test.dart`) drives a real drag into an edge band and asserts the container's `scrollTop` advances and collision resolves post-scroll. |
| Platform | `fvm dart analyze packages/dnd_kit_jaspr` clean; package keeps no Flutter dep and no top-level `dart:js_interop`/`package:web`. |
| Release | Public exports, `README.md`, and `CHANGELOG.md` mention the auto-scroll surface; `examples/jaspr_basic_drag_drop` (or a scroll-focused example) demonstrates it. |

## Harness Delta

No Harness process change expected; this is the first Phase 15 (Phase C)
hardening slice and extends the Jaspr adapter story trail only.

## Evidence

- Created 2026-06-16 as the first Phase C (hardening) story after Phase B closed
  (US-047 through US-055 implemented and verified).
- Implemented 2026-06-16:
  - Added `DndMeasuringRegistry.markAllDirty()` to `dnd_kit_core` (framework-neutral
    cache hook so an adapter can invalidate every measurement after an
    out-of-tree change such as auto-scroll).
  - Added `DndAutoScroll` to `dnd_kit_jaspr`
    (`lib/src/widgets/auto_scroll.dart`, exported from the barrel): a scroll
    viewport that, while the scope controller is dragging, runs a 16ms `Timer`
    loop computing velocity via the shared `dndAutoScrollVelocity`, applies
    `scrollTop`, then `markAllDirty()` + `moveDrag(currentPointer)` so collision
    re-resolves against post-scroll coordinates. Vertical only; horizontal
    deferred until a DOM-free horizontal axis exists in core. SSR-safe (DOM
    behind `kIsWeb`, no top-level `dart:js_interop`).
- Proof:
  - `fvm dart test packages/dnd_kit_core` -> 113 passed (incl. new
    `markAllDirty` measuring test).
  - `fvm dart test packages/dnd_kit_jaspr` -> 13 passed (VM suite unchanged).
  - `cd packages/dnd_kit_jaspr && fvm dart test -p chrome test/auto_scroll_browser_test.dart`
    -> 3 passed: scrolls while resting in the trailing edge band; resolves
    collision against a target scrolled into view (no further pointer move);
    does not scroll while disabled.
  - `fvm dart analyze packages/dnd_kit_core packages/dnd_kit_jaspr` -> No issues found.
- Release: `dnd_kit_jaspr` barrel, `README.md`, and `CHANGELOG.md` updated for the
  `DndAutoScroll` surface.
