# Changelog

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
