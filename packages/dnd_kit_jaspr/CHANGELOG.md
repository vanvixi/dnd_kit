# Changelog

## Unreleased

- Accessibility hardening: `DndLiveRegion` announces drag start, drag-over
  changes, drop, and cancel to screen readers via a configurable
  `DndAnnouncements` (English defaults), provided through `DndScope`. `DndDraggable`
  and `DndDragHandle` accept an accessible `label`; `DndDraggable` also accepts a
  keyboard-usage `description` exposed via `aria-describedby`. Keyboard drags keep
  focus on the activator. Derived from the shared runtime state, so it works for
  pointer, mouse, and keyboard drags alike.
- `DndAutoScroll`: drag-driven vertical auto-scroll for a Jaspr scroll
  container. It reuses the shared `dndAutoScrollVelocity` edge/velocity math from
  `dnd_kit_core` and only adds the browser execution layer (DOM measuring + a
  frame-interval `scrollTop` loop), staying SSR-safe. Collision re-resolves
  against post-scroll coordinates so a target scrolled into view is reachable.
  Horizontal auto-scroll is not yet supported.

## 0.1.0-dev.0

- Initial scaffold of the Jaspr adapter on the shared `dnd_kit_core` runtime.
- `DndController`: a Jaspr `ChangeNotifier` wrapper over `DndRuntime`.
- `DndScope` + `DndScope.of(context)` for providing the controller to a subtree.
- `DndDraggable` with the shared pointer sensor and DOM measuring hooks.
- `DndDroppable` with shared-runtime collision wiring and visual-state details.
- `DndDragHandle` for explicit handle-only activation in Jaspr trees.
- `DndDragOverlay` for fixed-position drag visuals that follow shared-runtime
  transform state.
- `DndDraggable` now differentiates mouse, touch, and keyboard activation:
  mouse drags immediately, touch waits for a hold by default, and keyboard
  pickup/move/drop flows report `DndInputKind.keyboard`.
- `DndDraggable` no longer mutates the source DOM node with the interim drag
  transform; active visuals now belong in `DndDragOverlay`.
- Browser tests now prove shared modifier effects for Jaspr drags, and the
  repository includes `examples/jaspr_basic_drag_drop` as the runnable app used
  for the current browser-proof work.
