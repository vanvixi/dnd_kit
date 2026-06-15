# 0010 Arena-Winning, Platform-Adaptive Draggable Activation

Date: 2026-06-14

## Status

Accepted

## Context

`DndDraggable` activated drags through a pan `GestureDetector`
(`PanGestureRecognizer`). Inside a vertical `Scrollable` (`ListView`,
`SingleChildScrollView`) that recognizer loses a pure-vertical drag to the
scrollable's `VerticalDragGestureRecognizer`, so drags never start. This forced
every example onto eager `SingleChildScrollView` layouts and blocked lazy
`ListView.builder` sortable lists (US-040). An `activationConstraint: distance`
does not change the arena outcome; only long-press activation or an initial
non-vertical move wins.

## Decision

Replace the pan gesture path with a `RawGestureDetector` driving Flutter's
`MultiDragGestureRecognizer` family, which is designed to win the drag-and-drop
arena over a scrollable. Activation becomes platform-adaptive by default:

- Mouse / precise pointers: `ImmediateMultiDragGestureRecognizer` (immediate).
- Touch / stylus: `DelayedMultiDragGestureRecognizer` (delayed / long-press
  style), matching `ReorderableListView` conventions.

Explicit `longPressActivation` (delayed on all kinds) and
`activationConstraint` (`distance` → immediate + distance gate on all kinds;
`delay` → delayed) continue to override the default. The fix lives in
`DndDraggable` core so every draggable — not just `SortableItem` — works inside
scrollables.

## Alternatives Considered

1. Fix only at the `SortableItem` layer — rejected: bare `DndDraggable` would
   stay broken in scrollables.
2. Keep `PanGestureRecognizer`, add `gestureSettings`/axis affinity — rejected:
   does not reliably win a pure-vertical drag inside a vertical scrollable.
3. Always-immediate custom recognizer on touch — rejected: conflicts with
   scrolling on mobile.
4. Default touch to long-press only — kept as the adaptive touch behavior, but
   paired with immediate mouse drag rather than long-press everywhere.

## Consequences

Positive:

- `DndDraggable` and `SortableItem` work inside vertical/horizontal scrollables,
  including lazy `ListView.builder`.
- Activation matches platform conventions (immediate mouse, delayed touch).
- Behavior change is contained to a pre-1.0 dev release.

Tradeoffs:

- Touch drags with default activation now require a short hold; non-scroll touch
  draggables that relied on immediate touch drag must opt into
  `activationConstraint: DndSensorActivationConstraint(distance: …)`.
- `DndDraggable` internals move from `GestureDetector` to `RawGestureDetector`;
  gesture-related tests are updated.

## Follow-Up

- Document the activation defaults in `docs/product/api-principles.md` and the
  package CHANGELOG.
- Revisit a sliver-based sortable API for very large lists (separate story).
