# dnd_kit_core

`dnd_kit_core` contains the pure Dart foundation for `dnd_kit`.

Use this package when you need drag-and-drop primitives, geometry, collision
detection, modifiers, registry contracts, or sensor contracts without depending
on Flutter.

## Import

```dart
import 'package:dnd_kit_core/dnd_kit_core.dart';
```

## What It Provides

- `DndId` for stable application-owned identifiers.
- `DndPoint`, `DndSize`, `DndRect`, and `DndTransform` for toolkit geometry.
- `DndState`, `DndDragSession`, and drag events for lifecycle modeling.
- `DndCollisionDetector` plus built-in detectors such as
  `DndCollisionDetectors.closestCenter`,
  `DndCollisionDetectors.closestCorners`,
  `DndCollisionDetectors.rectIntersection`, and
  `DndCollisionDetectors.pointerWithin`.
- `DndModifier` plus built-in modifiers such as
  `DndModifiers.restrictToVerticalAxis`,
  `DndModifiers.restrictToHorizontalAxis`,
  `DndModifiers.restrictToBoundary`, and `DndModifiers.snapToGrid`.
- `DndRegistry` and diagnostics hooks for draggable and droppable metadata.

## Package Boundary

`dnd_kit_core` intentionally has no Flutter dependency. It does not import
`package:flutter/*`, `dart:ui`, `BuildContext`, `RenderBox`, `Offset`, `Rect`,
or `Size`.

Flutter widgets, measuring, overlays, auto-scroll, and stable sortable presets
live in the main `dnd_kit` package.
