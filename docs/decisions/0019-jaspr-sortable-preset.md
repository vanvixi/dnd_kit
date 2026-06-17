# 0019 Jaspr Sortable Preset Reuses The Shared Engine

Date: 2026-06-17

## Status

Accepted

## Context

The Flutter adapter ships a sortable preset (`SortableScope`, `SortableItem`,
plus the experimental `SortableContainer`/`SortableMultiContainer` helpers). The
Jaspr adapter shipped its `0.3.0-dev.0` line without one, so Jaspr applications
could wire `DndDraggable`/`DndDroppable` for free-form drag-and-drop but had no
first-class reorder surface. This was the largest feature gap between the two
peer adapters.

The single-container reorder math is already framework-neutral and lives in the
engine (`package:dnd_kit`): `SortableStrategy`, `SortableStrategies.verticalList`/
`horizontalList`/`grid`, `SortableMoveDetails`, `SortableStrategyInput`.
`dnd_kit_jaspr` already re-exports the whole engine, so those types are visible
to Jaspr consumers today — only the component layer that drives them is missing.

The experimental multi-container helpers (`SortableContainer`,
`SortableMultiContainer`) are NOT in the engine: they live in `dnd_kit_flutter`
(`src/sortable/sortable_container.dart`), so Jaspr does not inherit them. They
are framework-neutral pure Dart and a candidate to hoist into the engine later;
multi-container sorting stays out of scope for this story and remains a
Flutter-only experimental feature for now.

## Decision

Add a Jaspr sortable preset as a thin component layer over the shared engine,
mirroring the Flutter adapter:

- `SortableScope` wraps `DndScope` and exposes the application-owned item order
  plus a pluggable `SortableStrategy` (default `verticalList`) through an
  `InheritedComponent`, read via `SortableScope.of`.
- `SortableItem` composes `DndDroppable` over `DndDraggable`, and on drag end
  asks the scope's `SortableScopeData.moveDetailsFor` — which calls the shared
  engine strategy with measured droppable rects — for a `SortableMoveDetails`
  reorder intent, forwarding it to `onMove`.

Because the strategy and move-details types are engine-level and already
re-exported, no engine or Flutter change is needed, and Jaspr inherits the
vertical/horizontal/grid single-container strategies automatically. The blast
radius is one package: `dnd_kit_jaspr` republishes (`0.3.0-dev.1`); `dnd_kit`
and `dnd_kit_flutter` are untouched. Multi-container sorting is explicitly out
of scope (see Context) and remains a Flutter-only experimental feature.

`SortableScopeData` is replicated in the Jaspr adapter (as it is in the Flutter
adapter) rather than hoisted into the engine: it depends on framework-neutral
engine types only, but each adapter keeps its own scope-data/InheritedComponent
plumbing so the change stays additive and adapter-local.

## Alternatives Considered

1. Hoist `SortableScopeData` into the engine and share it across both adapters.
   Rejected for now: it would force an engine version bump and a Flutter republish
   for a refactor with no consumer benefit. Revisit if a third adapter appears.
2. Ship only `verticalList` in Jaspr. Rejected: the strategies are engine
   functions already re-exported, so supporting all three (and multi-container)
   costs nothing extra once `SortableScope`/`SortableItem` exist.

## Consequences

Positive:

- Jaspr reaches single-container sortable parity with Flutter over one shared
  reorder engine, so both adapters compute identical move intent.
- Additive, adapter-local change; only `dnd_kit_jaspr` republishes.

Remaining gap:

- Multi-container sorting (`SortableContainer`/`SortableMultiContainer`) stays
  Flutter-only until those helpers are hoisted into the engine (a separate,
  cross-package decision). Jaspr apps can still move items across containers by
  driving `DndDraggable`/`DndDroppable` directly and computing their own intent.

Tradeoffs:

- `SortableScopeData` is duplicated across the Flutter and Jaspr adapters. The
  duplication is small and both delegate to the same engine math; ADR revisited
  if a third adapter makes hoisting worthwhile.
- The Jaspr `SortableItem` exposes state-aware rendering through its droppable
  layer's builder (Jaspr `DndDraggable` has no builder; drag visuals use
  `DndDragOverlay`), so its `builder` differs slightly in shape from Flutter's.
