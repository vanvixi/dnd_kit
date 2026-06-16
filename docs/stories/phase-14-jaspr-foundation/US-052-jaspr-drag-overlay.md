# US-052 Jaspr DndDragOverlay Via Fixed DOM Layer

## Status

implemented

## Lane

normal

## Product Contract

`dnd_kit_jaspr` must expose `DndDragOverlay` so active drags render through a
dedicated fixed-position DOM layer instead of mutating the source draggable's
DOM transform directly. The overlay keeps the shared-runtime contract aligned
with Flutter: it listens to controller state, follows the active transform, and
lets applications render custom drag content without owning drag state inside
their own subtree.

## Relevant Product Docs

- `docs/product/api-principles.md`
- `docs/product/package-architecture.md`
- `docs/ARCHITECTURE.md`
- `docs/decisions/0016-jaspr-adapter-scope-and-runtime-model.md`
- `SPEC_JASPR.md`

## Acceptance Criteria

- `dnd_kit_jaspr` exports `DndDragOverlay`, `DndDragOverlayDetails`, and the
  matching overlay builder typedef.
- `DndDragOverlay` renders nothing while the controller is idle, pending, or
  cancelled.
- While a drag is active, the overlay exposes active id, active rect,
  transform, session, and current `overId` to its builder.
- The overlay renders in a fixed-position DOM layer that follows the measured
  active rect plus the current drag transform.
- The overlay ignores pointer events by default, and `DndDraggable` no longer
  moves its own source DOM node with the interim transform path from US-049.

## Design Notes

- Commands:
  `fvm dart test packages/dnd_kit_jaspr`
  `cd packages/dnd_kit_jaspr && fvm dart test -p chrome test/draggable_browser_test.dart test/drag_overlay_browser_test.dart`
  `fvm dart analyze packages/dnd_kit_jaspr`
- Queries:
  `scripts/bin/harness-cli query matrix`
- API:
  `DndDragOverlay`
  `DndDragOverlayDetails`
  `DndDragOverlayBuilder`
- Domain rules:
  The overlay stays adapter-specific; the shared runtime still owns drag state,
  transform, and active rect truth.
  Applications keep owning their item data and choose overlay visuals through
  the builder.
- UI surfaces:
  Jaspr/browser DOM layer mounted from the component tree and positioned in
  viewport coordinates.

## Validation

When updating durable proof status, use numeric booleans:
`scripts/bin/harness-cli story update --id <id> --unit 1 --integration 1 --e2e 0 --platform 1`.

| Layer | Expected proof |
| --- | --- |
| Unit | Shared runtime state and transform math continue to flow through the controller contract; the overlay details surface is exercised from component tests. |
| Integration | `jaspr_test` proves lifecycle and builder details for idle/pending vs active overlay rendering. |
| E2E | Deferred to US-053 example/browser scenario proof. |
| Platform | Focused browser tests prove fixed DOM positioning, pointer-events behavior, and that the draggable source no longer applies the interim transform. |
| Release | Public exports, README, and changelog mention the new surface. |

## Harness Delta

No Harness process change expected; this is the next Phase 14 adapter slice.

## Evidence

- Verified 2026-06-16.
- `fvm dart test packages/dnd_kit_jaspr` -> 13 passed, including new
  `DndDragOverlay` idle/pending and active-details coverage.
- `cd packages/dnd_kit_jaspr && fvm dart test -p chrome test/draggable_browser_test.dart test/drag_overlay_browser_test.dart`
  -> 5 passed, including fixed-position overlay DOM assertions and proof that
  `DndDraggable` no longer mutates its source node transform during pointer
  drags.
- `fvm dart analyze packages/dnd_kit_jaspr` -> No issues found.
- Public package surface updated in
  `packages/dnd_kit_jaspr/lib/dnd_kit_jaspr.dart`, `README.md`, and
  `CHANGELOG.md`.
