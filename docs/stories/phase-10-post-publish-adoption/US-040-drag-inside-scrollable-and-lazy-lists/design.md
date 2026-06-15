# Design

## Domain Model

No new pure-Dart value objects. The change is in the Flutter adapter
(`packages/dnd_kit`). Existing contracts reused:

- `DndPointerSensor` — the activation + state-machine driver.
- `DndSensorActivationConstraint` — `none` / `distance` / `delay`.
- `DndController.measuring` — adapter-owned measured rects.

## Application Flow

### Layer 1 — Arena-winning activation (DndDraggable)

Replace `GestureDetector(onPanStart/Update/End/Cancel)` with a
`RawGestureDetector` whose recognizer is chosen per pointer device kind, using
Flutter's drag-and-drop recognizers that are built to win the arena over a
`Scrollable`:

| Activation | Mouse / precise pointer | Touch / stylus |
| --- | --- | --- |
| `longPressActivation` set | `DelayedMultiDragGestureRecognizer(delay)` | `DelayedMultiDragGestureRecognizer(delay)` |
| `activationConstraint: none` (default) | `ImmediateMultiDragGestureRecognizer` | `DelayedMultiDragGestureRecognizer(kLongPressTimeout)` |
| `activationConstraint: distance(d)` | `ImmediateMultiDragGestureRecognizer` + sensor distance gate | `ImmediateMultiDragGestureRecognizer` + sensor distance gate |
| `activationConstraint: delay(t)` | `DelayedMultiDragGestureRecognizer(t)` | `DelayedMultiDragGestureRecognizer(t)` |

`MultiDragGestureRecognizer.onStart(Offset)` returns a `Drag`. We return a thin
`_DndDragProxy implements Drag` that forwards:

- `update(DragUpdateDetails)` → `_pointerSensor.move(globalPosition)`
- `end(DragEndDetails)` → `_pointerSensor.end()`
- `cancel()` → `_pointerSensor.cancel(reason: sensor)`

`onStart` is where we create/start the `DndPointerSensor` (replacing
`_handlePanStart`). The recognizer already enforced delay/slop and won the
arena, so the sensor's job narrows to the DnD state machine; for the immediate
`distance` case the sensor keeps gating on distance before `startDrag`.

Drag handles: `DndDragHandle` currently relies on the same gesture path. The
handle scope still routes pointer activation; the recognizer lives on the
draggable (or handle) subtree. Handle gating (`_handleCount`, `fromHandle`) is
preserved by only attaching the active recognizer where appropriate.

Keyboard drag, disabled handling, semantics: unchanged (separate `Focus` /
`Listener` paths).

### Layer 2 — Partial-measurement strategies (SortableStrategies)

Today each geometry strategy does: for every non-active `id`, read
`itemRects[id]`; if any is `null`, `return fallback`. Change to: build
`measuredItems` from the ids that **do** have a rect, skip the unmeasured ones,
and compute the insertion index among the measured set. Anchor the result to
the real `itemIds` order so the returned `toIndex` stays in list space.

Rules:

- If fewer than 1 measured neighbour exists, keep returning `fallback`.
- Insertion index is computed in measured-subset space, then mapped back to the
  full `itemIds` index of the boundary item, so visible-only measurement still
  yields a correct list index relative to the over target.
- Keep the existing separation guards (`_hasVerticalSeparation`, etc.) but over
  the measured subset.

### Layer 3 — Active item lifecycle (DndController + DndDraggable)

When the active item's `DndDraggable` is disposed mid-drag (lazy recycle), do
not drop its registration/rect from the controller. Approach:

- `DndController` snapshots the active draggable's `DndDraggableRegistration`
  and measured rect at drag start (it already caches `activeRect`).
- `DndDraggable._unregister()` skips unregister/`removeDraggableRect` when
  `controller.activeId == widget.id` and a drag is active; the controller
  restores/keeps the snapshot until `reset()`.

This keeps `registry.draggable(activeId)` and `measuring.draggableRect` stable
for the whole session even if the element is recycled.

## Interface Contract

- `DndDraggable` constructor stays source-compatible (same parameters). Default
  **runtime behavior** changes for touch (now delayed) — documented as a
  behavior change in CHANGELOG and `0010` decision.
- No change to `dnd_kit_core` public API except, if needed, additive helpers on
  strategy input; prefer to keep strategy logic inside `dnd_kit`.

## Data Model

None.

## UI / Platform Impact

- Mobile (touch): default sortable/draggable now activates on a short delay
  (long-press style) so it can coexist with scrolling. Explicit immediate via
  `activationConstraint: DndSensorActivationConstraint(distance: …)`.
- Desktop/web (mouse): immediate drag, unchanged feel, now also works inside
  scrollables.
- Examples updated; at least one (`basic_drag_drop` or `multi_container_sortable`)
  uses `ListView.builder`.

## Observability

Reuse existing `DndWarning`/diagnostics. No new logs required.

## Alternatives Considered

1. Default touch to long-press only at the `SortableItem` layer — rejected:
   leaves bare `DndDraggable` broken in scrollables (not "triệt để").
2. Keep `PanGestureRecognizer` but add `gestureSettings`/`affinity` — rejected:
   does not reliably win a pure-vertical drag inside a vertical scrollable.
3. Always-immediate custom recognizer on touch — rejected by human: conflicts
   with scrolling on mobile.
4. Virtualize off-screen measurement so strategies always see all rects —
   rejected: defeats the point of lazy lists and is expensive.
