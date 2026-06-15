# Overview

## Current Behavior

`DndDraggable` wires drag activation through a `GestureDetector`
(`onPanStart/onPanUpdate/onPanEnd`), i.e. a `PanGestureRecognizer`. When a
draggable sits inside a vertical `Scrollable` (`ListView`,
`SingleChildScrollView`), that pan recognizer competes with the scrollable's
`VerticalDragGestureRecognizer` in the gesture arena and loses a pure-vertical
drag. Reproduced (temporary tests, now removed):

- No scrollable: drag starts and tracks the pointer.
- Inside `SingleChildScrollView` (vertical): `isDragging` stays `false`,
  drag never starts. Same for `ListView.builder`.
- `activationConstraint: distance` does **not** fix it; only
  `longPressActivation` (or an initial horizontal move) wins the arena.

Because of this, every example uses an eager `SingleChildScrollView` plus a
non-vertical or long-press escape hatch, so lists cannot lazily build.

Two further problems surface specifically with lazy `ListView.builder`:

- Geometry sortable strategies (`verticalList`/`horizontalList`/`grid`) require
  a measured rect for **every** non-active item from
  `controller.measuring.droppableRects`. Lazy lists only build/measure the
  viewport, so any missing rect makes strategies silently fall back to
  over-id-only reordering.
- When the active item scrolls out of the viewport its element is destroyed,
  `DndDraggable.dispose()` unregisters the draggable and drops its measured
  rect. The session survives via the controller's cached `activeRect`, but the
  source item's registry/visual state is lost mid-drag.

## Target Behavior

- A `DndDraggable` (and therefore `SortableItem`) can start and track a drag
  while inside a vertical or horizontal `Scrollable`, including lazy
  `ListView.builder`, using a gesture recognizer that wins the arena.
- Activation is platform-adaptive by default: precise pointers (mouse) drag
  immediately; touch uses a delayed (long-press style) activation, matching
  `ReorderableListView` conventions. Explicit `activationConstraint` and
  `longPressActivation` continue to override the default.
- Sortable geometry strategies produce correct insertion intent using the
  subset of items currently measured (visible), instead of bailing to fallback
  when off-screen items are unmeasured.
- The active dragged item keeps a stable registration and measured rect for the
  whole session even if the lazy list recycles its element.
- At least one example uses `ListView.builder` and proves lazy sortable lists
  work end to end.

## Affected Users

- Package adopters building scrollable sortable lists, Kanban columns, and long
  drag-and-drop lists on mobile, desktop, and web.

## Affected Product Docs

- `docs/product/api-principles.md` (activation defaults, gesture contract)
- `docs/product/overview.md` (sortable in scrollables)
- `docs/ARCHITECTURE.md` (gesture/boundary note, if behavior is documented)

## Non-Goals

- Native OS drag-and-drop.
- Virtualized measurement of off-screen items (we accept partial measurement).
- Sliver-based sortable APIs (`SliverList` integration) — future work.
- Changing the pure-Dart core collision/strategy contracts beyond what partial
  measurement requires.
