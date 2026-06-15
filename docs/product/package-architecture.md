# Package Architecture

## Monorepo Shape

```text
packages/
  dnd_kit_core/     # pure Dart engine, shared by every adapter
  dnd_kit_flutter/  # Flutter adapter
  dnd_kit/          # umbrella that re-exports dnd_kit_flutter
examples/
  basic_drag_drop/
docs/
```

The framework-agnostic `dnd_kit_core` is the shared engine. `dnd_kit_flutter`
is the Flutter adapter built on top of it. `dnd_kit` is a thin umbrella that
re-exports `dnd_kit_flutter` under the shorter, brand name. This layout leaves
room for additional framework adapters (for example a future `dnd_kit_jaspr`)
that reuse `dnd_kit_core` without touching the Flutter adapter.

## Package Boundaries

### `dnd_kit_core`

Pure Dart package with no Flutter dependency.

Owns:

- `DndId`
- `DndPoint`, `DndSize`, `DndRect`, `DndTransform`
- drag state and session models
- collision detector contracts and built-in algorithms
- modifier contracts and pure Dart modifiers
- sensor contracts
- registry contracts
- base sortable math

Must not import:

- `package:flutter/*`
- `dart:ui`
- `BuildContext`
- `RenderBox`
- `Offset`, `Rect`, or `Size` from Flutter
- animation or overlay APIs

### `dnd_kit_flutter`

Flutter adapter package depending on `dnd_kit_core` and Flutter. This is the
package that owns the Flutter widget, sensor, measuring, overlay, and sortable
implementation.

Owns:

- `DndScope`
- `DndController`
- `DndDraggable`
- `DndDroppable`
- `DndDragHandle`
- `DndDragOverlay`
- pointer, mouse, touch, long-press, and keyboard sensors
- Flutter measuring and geometry adapters
- overlay rendering
- auto-scroll
- semantics and accessibility hooks
- stable sortable preset APIs

Also owns sortable preset source:

- `SortableScope`
- `SortableItem`
- `SortableContainer`
- `SortableStrategy`
- `SortableStrategies`
- `SortableMoveDetails`
- sortable keyboard coordinates

Stable V1 strategies are vertical list, horizontal list, and grid.
Multi-container, nested sortable, and virtualized adapters remain experimental.

### `dnd_kit`

Thin umbrella package depending only on `dnd_kit_flutter`. Its single library
`package:dnd_kit/dnd_kit.dart` re-exports `package:dnd_kit_flutter/dnd_kit_flutter.dart`
so applications can use the shorter import with an identical API.

Must not:

- contain adapter logic of its own
- be depended on by `dnd_kit_core` or `dnd_kit_flutter` (no upward dependency)

## Dependency Policy

Core runtime dependencies stay minimal:

- `collection`
- `meta`

Core must not use:

- `vector_math`
- `provider`
- `riverpod`
- `bloc`
- `freezed`
- `equatable`

Flutter packages may depend on Flutter SDK packages, but should avoid locking
users into an app state management approach.

## SDK Policy

The package family targets:

```yaml
environment:
  sdk: ">=3.5.0 <4.0.0"
  flutter: ">=3.24.0"
```
