# dnd_kit_core Example

`dnd_kit_core` provides pure Dart geometry, collision, modifier, state, sensor,
registry, and diagnostics primitives. It has no Flutter dependency.

```dart
import 'package:dnd_kit_core/dnd_kit_core.dart';

void main() {
  const activeRect = DndRect(left: 0, top: 0, width: 80, height: 40);
  const droppableRects = <DndId, DndRect>{
    DndId('todo'): DndRect(left: 0, top: 80, width: 240, height: 200),
    DndId('done'): DndRect(left: 280, top: 80, width: 240, height: 200),
  };

  final collisions = DndCollisionDetectors.closestCenter(
    const DndCollisionInput(
      activeRect: activeRect,
      droppableRects: droppableRects,
    ),
  );

  final overId = collisions.isEmpty ? null : collisions.first.id;
  print('Dragging over: ${overId?.value}');
}
```

Use `dnd_kit_core` directly when you need testable drag/drop math or contracts
without Flutter widgets. Use the main
[`dnd_kit`](https://pub.dev/packages/dnd_kit) package for Flutter scopes,
draggables, droppables, overlays, sensors, auto-scroll, and sortable presets.
