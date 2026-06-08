# `dnd_kit` Flutter — Product & Technical SPEC v0.1

## 1. Product Summary

`dnd_kit` is a drag-and-drop toolkit for Flutter, inspired by React dnd-kit but redesigned around Flutter’s widget, render, gesture, and state models.

The main goal is to provide a **generic draggable/droppable engine** powerful enough to build:

- basic drag and drop;
- sortable lists;
- sortable grids;
- Kanban boards;
- dashboard builders;
- canvas editors;
- form/page builders;
- admin UIs for web and desktop;
- mobile UIs with long-press dragging.

`dnd_kit` v1 treats **mobile, web, and desktop** as first-class targets from the beginning.

---

# 2. Product Goals

## 2.1 Goals

`dnd_kit` must satisfy the following goals:

1. **Generic engine first, presets second**
   The core must solve the draggable/droppable problem first. Sortable and Kanban are preset/showcase layers, not the foundation of the architecture.

2. **Flutter-style API**
   Public API should use Flutter-style naming such as `DndScope`, `DndDraggable`, `DndDroppable`, `DndDragOverlay`, `SortableScope`, and `SortableItem`.

3. **Production-grade**
   The library must be predictable, testable, extensible, and suitable for real apps, not just demos.

4. **Composable**
   Users should be able to integrate it with `setState`, Riverpod, BLoC, Provider, Redux, or any other state management approach without being locked in.

5. **Extensible**
   The library must support custom sensors, collision detectors, modifiers, measuring strategies, drag overlays, and sortable strategies.

6. **Stable public API early**
   Core public APIs should be designed and frozen early to avoid painful breaking changes later.

7. **Type-safe with Dart 3**
   The implementation should take advantage of Dart 3 features such as `sealed class`, `interface class`, `final class`, pattern matching, and exhaustive switch statements.

---

## 2.2 Non-goals

V1 is not intended to replace native OS-level drag and drop.

The following are **not part of stable v1**:

- dragging files from Finder/Explorer into a Flutter app;
- dragging items from a Flutter app to the OS;
- native file drag and drop;
- cross-window drag and drop;
- cross-app drag and drop;
- full virtualized variable-height sortable lists;
- complex nested sortable layouts;
- highly opinionated animation systems;
- dependency on external state management libraries such as Riverpod, Provider, or BLoC.

Native OS drag and drop, if supported later, should be implemented in a separate package:

```text
dnd_kit_native
```

---

# 3. Package Architecture

The project should use a mono-repo structure.

```text
dnd_kit/
  packages/
    dnd_kit_core/
    dnd_kit_flutter/
    dnd_kit_sortable/
    dnd_kit/
  examples/
    basic_drag_drop/
    drag_overlay/
    sortable_list/
    sortable_grid/
    kanban_board/
    custom_collision/
    custom_sensor/
    auto_scroll/
    keyboard_accessibility/
  docs/
    architecture.md
    api_design.md
    collision_detection.md
    sensors.md
    modifiers.md
    measuring.md
    sortable.md
    accessibility.md
```

---

## 3.1 `dnd_kit_core`

Pure Dart package.

No Flutter dependency.

### Contains

```text
- DndId
- DndPoint
- DndSize
- DndRect
- DndTransform
- DndState
- DndDragSession
- DndActive
- DndOver
- DndCollision
- DndCollisionDetector
- built-in collision algorithms
- DndModifier
- sensor contracts
- event models
- registry contracts
- base sortable math
```

### Does not contain

```text
- Widget
- BuildContext
- RenderBox
- Flutter Offset / Rect / Size
- AnimationController
- GestureDetector
- OverlayEntry
```

---

## 3.2 `dnd_kit_flutter`

Flutter adapter package.

Depends on:

```yaml
dependencies:
  dnd_kit_core: ^0.1.0
  flutter:
    sdk: flutter
```

### Contains

```text
- DndScope
- DndController
- DndDraggable
- DndDroppable
- DndDragHandle
- DndDragOverlay
- pointer/mouse/touch/keyboard sensors
- measuring system
- Flutter geometry adapter
- auto-scroll
- overlay rendering
- accessibility/semantics
```

---

## 3.3 `dnd_kit_sortable`

Sortable preset package.

Depends on:

```yaml
dependencies:
  dnd_kit_core: ^0.1.0
  dnd_kit_flutter: ^0.1.0
```

### Contains

```text
- SortableScope
- SortableItem
- SortableContainer
- SortableStrategy
- SortableStrategies
- SortableMoveDetails
- sortable keyboard coordinates
```

Stable in v1:

```text
- vertical list
- horizontal list
- grid
```

Experimental in v1:

```text
- multi-container sortable
- nested sortable
- virtualized adapter
```

---

## 3.4 `dnd_kit`

Umbrella package.

Exports all public APIs from the sub-packages:

```dart
library dnd_kit;

export 'package:dnd_kit_core/dnd_kit_core.dart';
export 'package:dnd_kit_flutter/dnd_kit_flutter.dart';
export 'package:dnd_kit_sortable/dnd_kit_sortable.dart';
```

Users can install the full package:

```yaml
dependencies:
  dnd_kit: ^0.1.0
```

Or use only the core package:

```yaml
dependencies:
  dnd_kit_core: ^0.1.0
```

---

# 4. SDK & Dependency Policy

## 4.1 Minimum SDK

Recommended:

```yaml
environment:
  sdk: ">=3.5.0 <4.0.0"
  flutter: ">=3.24.0"
```

Reasons:

- modern enough to use Dart 3 type-system features;
- not too new, so adoption remains broad;
- suitable for a production package with a type-safe API;
- enables clean modeling of state machines, events, constraints, and extension points.

---

## 4.2 Runtime Dependencies

Keep runtime dependencies minimal.

### `dnd_kit_core`

```yaml
dependencies:
  collection: ^1.19.0
  meta: ^1.15.0
```

Use `collection` for:

```text
- equality helpers
- iterable utilities
- sorting helpers
- small data-structure utilities
```

Use `meta` for:

```text
- @immutable
- @internal
- @visibleForTesting
- @experimental
- @mustCallSuper
```

### Do not use in v1 core

```text
- vector_math
- provider
- riverpod
- bloc
- freezed
- equatable
```

Core geometry should define its own `DndPoint`, `DndRect`, and `DndTransform` to keep the API clean and stable.

---

## 4.3 Dev Dependencies

```yaml
dev_dependencies:
  test: any
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  fake_async: ^1.3.0
```

`fake_async` is useful for deterministic tests involving timers, delays, long press behavior, measuring throttling, and auto-scroll.

---

# 5. API Principles

## 5.1 Flutter-style Naming

Use:

```text
DndScope
DndDraggable
DndDroppable
DndDragHandle
DndDragOverlay
SortableScope
SortableItem
```

Avoid React-style naming:

```text
DndContext
useDraggable
useDroppable
DragOverlayContext
```

Reason: Flutter developers are already familiar with concepts such as `Scope`, `Controller`, `Builder`, `Item`, and `Handle`.

---

## 5.2 Controlled & Uncontrolled Controller

`DndScope` must support both controlled and uncontrolled modes.

### Uncontrolled

```dart
DndScope(
  child: App(),
)
```

`DndScope` creates and owns an internal controller.

### Controlled

```dart
final controller = DndController();

DndScope(
  controller: controller,
  child: App(),
)
```

Rules:

```text
- If the user provides a controller, the user owns its lifecycle.
- If no controller is provided, DndScope creates and disposes an internal controller.
- DndScope must not dispose an external controller.
```

---

## 5.3 Users Own Their Data

The library must **not mutate user data**.

Sortable example:

```dart
SortableScope(
  ids: tasks.map((e) => DndId(e.id)).toList(),
  onReorder: (details) {
    setState(() {
      final item = tasks.removeAt(details.oldIndex);
      tasks.insert(details.newIndex, item);
    });
  },
  child: ...
)
```

The library reports intent. The application owns mutation.

---

## 5.4 Stable ID Requirement

`DndId` must be stable during the widget lifecycle.

```dart
final class DndId {
  const DndId(this.value);

  final Object value;

  @override
  bool operator ==(Object other) {
    return other is DndId && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}
```

Avoid:

```dart
DndId(UniqueKey())
DndId(DateTime.now())
DndId(Object())
```

Prefer:

```dart
DndId(task.id)
DndId('column-todo')
DndId(user.id)
```

---

# 6. Core Domain Model

## 6.1 Geometry

```dart
@immutable
final class DndPoint {
  const DndPoint(this.x, this.y);

  final double x;
  final double y;
}

@immutable
final class DndSize {
  const DndSize(this.width, this.height);

  final double width;
  final double height;
}

@immutable
final class DndRect {
  const DndRect({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  final double left;
  final double top;
  final double width;
  final double height;

  double get right => left + width;
  double get bottom => top + height;

  DndPoint get center => DndPoint(
        left + width / 2,
        top + height / 2,
      );
}
```

---

## 6.2 Transform

```dart
@immutable
final class DndTransform {
  const DndTransform({
    this.x = 0,
    this.y = 0,
    this.scaleX = 1,
    this.scaleY = 1,
  });

  final double x;
  final double y;
  final double scaleX;
  final double scaleY;

  static const zero = DndTransform();
}
```

---

## 6.3 Drag State

```dart
sealed class DndState {
  const DndState();
}

final class DndIdle extends DndState {
  const DndIdle();
}

final class DndPending extends DndState {
  const DndPending({
    required this.activeId,
    required this.origin,
  });

  final DndId activeId;
  final DndPoint origin;
}

final class DndDragging extends DndState {
  const DndDragging({
    required this.session,
  });

  final DndDragSession session;
}

final class DndDropping extends DndState {
  const DndDropping({
    required this.session,
  });

  final DndDragSession session;
}

final class DndCancelled extends DndState {
  const DndCancelled({
    required this.reason,
  });

  final DndCancelReason reason;
}
```

---

## 6.4 Drag Session

```dart
@immutable
final class DndDragSession {
  const DndDragSession({
    required this.active,
    required this.initialPointer,
    required this.currentPointer,
    required this.delta,
    required this.collisions,
    required this.over,
    required this.inputKind,
  });

  final DndActive active;
  final DndPoint initialPointer;
  final DndPoint currentPointer;
  final DndPoint delta;
  final List<DndCollision> collisions;
  final DndOver? over;
  final DndInputKind inputKind;
}
```

---

# 7. Flutter Public API

## 7.1 `DndScope`

```dart
class DndScope extends StatefulWidget {
  const DndScope({
    super.key,
    this.controller,
    this.sensors = const [
      DndPointerSensor(),
      DndKeyboardSensor(),
    ],
    this.collisionDetector = DndCollisionDetectors.closestCenter,
    this.modifiers = const [],
    this.measuring = const DndMeasuringConfig(),
    this.autoScroll = const DndAutoScrollConfig.disabled(),
    this.onDragStart,
    this.onDragMove,
    this.onDragOver,
    this.onDragEnd,
    this.onDragCancel,
    required this.child,
  });

  final DndController? controller;
  final List<DndSensor> sensors;
  final DndCollisionDetector collisionDetector;
  final List<DndModifier> modifiers;
  final DndMeasuringConfig measuring;
  final DndAutoScrollConfig autoScroll;

  final DndDragStartCallback? onDragStart;
  final DndDragMoveCallback? onDragMove;
  final DndDragOverCallback? onDragOver;
  final DndDragEndCallback? onDragEnd;
  final DndDragCancelCallback? onDragCancel;

  final Widget child;
}
```

---

## 7.2 `DndDraggable`

```dart
class DndDraggable<T> extends StatefulWidget {
  const DndDraggable({
    super.key,
    required this.id,
    this.data,
    this.disabled = false,
    this.activationConstraint,
    this.feedback = const DndFeedback.child(),
    this.builder,
    required this.child,
  });

  final DndId id;
  final T? data;
  final bool disabled;
  final DndActivationConstraint? activationConstraint;
  final DndFeedback feedback;
  final DndDraggableWidgetBuilder? builder;
  final Widget child;
}
```

---

## 7.3 `DndDragHandle`

```dart
DndDraggable<Task>(
  id: DndId(task.id),
  data: task,
  child: TaskCard(
    leading: const DndDragHandle(
      child: Icon(Icons.drag_indicator),
    ),
    title: task.title,
  ),
)
```

Rules:

```text
- If DndDraggable has no DndDragHandle child, the whole child acts as the drag activator.
- If one or more DndDragHandle widgets exist, only handles can activate dragging.
```

---

## 7.4 `DndDroppable`

```dart
class DndDroppable<T> extends StatefulWidget {
  const DndDroppable({
    super.key,
    required this.id,
    this.data,
    this.disabled = false,
    this.accepts,
    this.builder,
    required this.child,
  });

  final DndId id;
  final T? data;
  final bool disabled;
  final DndAcceptsCallback? accepts;
  final DndDroppableWidgetBuilder? builder;
  final Widget child;
}
```

Example:

```dart
DndDroppable<BoardColumn>(
  id: DndId(column.id),
  data: column,
  accepts: (active, self) => active.data is Task,
  builder: (context, state, child) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          width: state.isOver ? 2 : 1,
        ),
      ),
      child: child,
    );
  },
  child: ColumnView(column),
)
```

---

## 7.5 `DndDragOverlay`

```dart
DndDragOverlay(
  builder: (context, active) {
    final task = active.data as Task;

    return TaskCard(
      task: task,
      elevated: true,
    );
  },
)
```

Rules:

```text
- Overlay renders independently from the source layout.
- Overlay does not affect the size/layout of the original widget.
- Overlay follows the pointer using transform/listenable updates.
- Overlay must not rebuild the entire app on every pointer move.
```

---

# 8. Collision Detection

## 8.1 API

```dart
typedef DndCollisionDetector = List<DndCollision> Function(
  DndCollisionArgs args,
);
```

```dart
final class DndCollisionArgs {
  const DndCollisionArgs({
    required this.activeRect,
    required this.droppables,
    required this.pointer,
  });

  final DndRect activeRect;
  final List<DndDroppableEntry> droppables;
  final DndPoint? pointer;
}
```

---

## 8.2 Built-in Detectors

```dart
abstract final class DndCollisionDetectors {
  static List<DndCollision> closestCenter(DndCollisionArgs args) {}
  static List<DndCollision> closestCorners(DndCollisionArgs args) {}
  static List<DndCollision> rectIntersection(DndCollisionArgs args) {}
  static List<DndCollision> pointerWithin(DndCollisionArgs args) {}

  static DndCollisionDetector compose(
    List<DndCollisionDetector> detectors,
  ) {}
}
```

---

## 8.3 Custom Detector Example

```dart
final kanbanCollisionDetector = DndCollisionDetectors.compose([
  DndCollisionDetectors.pointerWithin,
  DndCollisionDetectors.closestCenter,
]);
```

---

# 9. Modifiers

## 9.1 API

```dart
abstract interface class DndModifier {
  const DndModifier();

  DndTransform apply(DndModifierArgs args);
}
```

```dart
final class DndModifierArgs {
  const DndModifierArgs({
    required this.transform,
    required this.activeRect,
    required this.pointer,
    this.containerRect,
  });

  final DndTransform transform;
  final DndRect activeRect;
  final DndPoint pointer;
  final DndRect? containerRect;
}
```

---

## 9.2 Built-in Modifiers

```text
RestrictToVerticalAxis
RestrictToHorizontalAxis
RestrictToWindowBounds
RestrictToParentBounds
RestrictToScrollableAncestor
SnapToGrid
ClampOffset
```

---

# 10. Sensors

## 10.1 Built-in Sensors v1

```text
DndPointerSensor
DndMouseSensor
DndTouchSensor
DndLongPressSensor
DndKeyboardSensor
```

---

## 10.2 Activation Constraints

```dart
sealed class DndActivationConstraint {
  const DndActivationConstraint();
}

final class DndDistanceConstraint extends DndActivationConstraint {
  const DndDistanceConstraint(this.distance);

  final double distance;
}

final class DndDelayConstraint extends DndActivationConstraint {
  const DndDelayConstraint({
    required this.delay,
    required this.tolerance,
  });

  final Duration delay;
  final double tolerance;
}

final class DndLongPressConstraint extends DndActivationConstraint {
  const DndLongPressConstraint({
    required this.delay,
    this.hapticFeedback = true,
  });

  final Duration delay;
  final bool hapticFeedback;
}
```

---

# 11. Measuring System

## 11.1 Goals

The measuring system must:

```text
- measure draggable rects;
- measure droppable rects;
- cache rects by DndId;
- convert local/global coordinates consistently;
- re-measure when scroll or layout changes;
- avoid calling findRenderObject on every pointer move;
- avoid running collision detection more than once per frame.
```

---

## 11.2 Config

```dart
enum DndMeasuringStrategy {
  beforeDragging,
  whileDragging,
  always,
}
```

```dart
final class DndMeasuringConfig {
  const DndMeasuringConfig({
    this.strategy = DndMeasuringStrategy.whileDragging,
    this.throttle,
    this.measureDroppablesOnScroll = true,
    this.measureActiveDraggable = true,
  });

  final DndMeasuringStrategy strategy;
  final Duration? throttle;
  final bool measureDroppablesOnScroll;
  final bool measureActiveDraggable;
}
```

---

# 12. Auto-scroll

## 12.1 Config

```dart
final class DndAutoScrollConfig {
  const DndAutoScrollConfig({
    required this.enabled,
    this.threshold = 48,
    this.maxSpeed = 24,
    this.axis,
  });

  const DndAutoScrollConfig.enabled()
      : enabled = true,
        threshold = 48,
        maxSpeed = 24,
        axis = null;

  const DndAutoScrollConfig.disabled()
      : enabled = false,
        threshold = 48,
        maxSpeed = 24,
        axis = null;

  final bool enabled;
  final double threshold;
  final double maxSpeed;
  final Axis? axis;
}
```

---

## 12.2 V1 Behavior

```text
- scroll the nearest scrollable container to the pointer;
- support vertical ListView;
- support horizontal scrolling;
- support basic nested scrolling;
- stop immediately on drop/cancel;
- do not scroll when the pointer is not near an edge.
```

---

# 13. Sortable Preset

## 13.1 `SortableScope`

```dart
SortableScope(
  ids: tasks.map((task) => DndId(task.id)).toList(),
  strategy: SortableStrategies.verticalList,
  onReorder: (details) {
    setState(() {
      final task = tasks.removeAt(details.oldIndex);
      tasks.insert(details.newIndex, task);
    });
  },
  child: ListView(
    children: [
      for (final task in tasks)
        SortableItem(
          id: DndId(task.id),
          child: TaskCard(task),
        ),
    ],
  ),
)
```

---

## 13.2 `SortableItem`

```dart
SortableItem(
  id: DndId(task.id),
  child: TaskCard(task),
)
```

---

## 13.3 Strategies

```dart
abstract final class SortableStrategies {
  static const verticalList = VerticalListSortableStrategy();
  static const horizontalList = HorizontalListSortableStrategy();
  static const grid = GridSortableStrategy();
}
```

---

## 13.4 Multi-container Preparation

V1 should include model types for future multi-container support, but the full API does not need to be stable yet.

```dart
@experimental
final class SortableContainer {
  const SortableContainer({
    required this.id,
    required this.itemIds,
  });

  final DndId id;
  final List<DndId> itemIds;
}
```

```dart
final class SortableMoveDetails {
  const SortableMoveDetails({
    required this.activeId,
    required this.fromContainerId,
    required this.toContainerId,
    required this.oldIndex,
    required this.newIndex,
  });

  final DndId activeId;
  final DndId fromContainerId;
  final DndId toContainerId;
  final int oldIndex;
  final int newIndex;

  bool get isSameContainer => fromContainerId == toContainerId;
}
```

---

# 14. User Stories & Acceptance Criteria

## Phase 0 — Repo Foundation & Architecture Freeze

### Goal

Set up the mono-repo, package structure, coding conventions, API direction, and basic CI.

---

### User Story 0.1 — Maintainer sets up the repo

**As a maintainer**, I want the repo to be split into clear packages so core, Flutter adapter, sortable preset, and umbrella package can be developed independently.

#### Acceptance Criteria

- Repo has the following structure:

```text
packages/dnd_kit_core
packages/dnd_kit_flutter
packages/dnd_kit_sortable
packages/dnd_kit
examples/
docs/
```

- Each package has its own `pubspec.yaml`.
- `dnd_kit` exports all three sub-packages.
- `melos bootstrap` runs successfully.
- `dart analyze` passes for the whole repo.
- Root `README.md` explains the library goal.
- `docs/architecture.md` exists.

---

### User Story 0.2 — Developer installs umbrella package

**As a Flutter developer**, I want to install only `dnd_kit` and get access to core, Flutter, and sortable APIs.

#### Acceptance Criteria

- This import works:

```dart
import 'package:dnd_kit/dnd_kit.dart';
```

- After importing, the user can access:

```text
DndId
DndScope
DndDraggable
DndDroppable
DndDragOverlay
SortableScope
SortableItem
```

- Example app compiles with only `dnd_kit` as a dependency.

---

### User Story 0.3 — Developer installs only core

**As an advanced developer**, I want to install only `dnd_kit_core` so I can use collision, modifier, and state-machine logic without Flutter.

#### Acceptance Criteria

- `dnd_kit_core` does not import Flutter.
- `dart test` runs in the core package without Flutter SDK.
- `dnd_kit_core` exposes geometry, collision, and state-machine APIs.
- Core `pubspec.yaml` has no Flutter dependency.

---

## Phase 1 — Core Engine

### Goal

Build the pure Dart foundation: ID, geometry, state machine, event models, collision detectors, and modifier contracts.

---

### User Story 1.1 — Stable ID

**As an app developer**, I want to identify draggable and droppable elements with stable IDs so the library can track items correctly across rebuilds.

#### Acceptance Criteria

- `DndId` exists.
- `DndId` accepts `Object value`.
- Two `DndId`s with the same value are equal.
- `DndId` can be used as a key in `Map<DndId, ...>`.
- Equality/hashCode tests exist.
- Duplicate IDs in the same registry are detected in debug mode.

---

### User Story 1.2 — Pure Dart geometry

**As a maintainer**, I want the core package to have its own geometry types so collision algorithms can be tested independently from Flutter.

#### Acceptance Criteria

- `DndPoint`, `DndSize`, `DndRect`, and `DndTransform` exist.
- Core does not import `dart:ui`.
- Core does not import Flutter.
- Helper methods exist:

```text
DndRect.center
DndRect.right
DndRect.bottom
DndRect.contains
DndRect.intersects
```

- Unit tests exist for geometry methods.

---

### User Story 1.3 — Drag state machine

**As a maintainer**, I want the drag lifecycle to be modeled by a clear state machine to avoid inconsistent runtime state.

#### Acceptance Criteria

- These states exist:

```text
DndIdle
DndPending
DndDragging
DndDropping
DndCancelled
```

- Valid transitions:

```text
idle -> pending
pending -> dragging
pending -> cancelled
dragging -> dropping
dragging -> cancelled
dropping -> idle
cancelled -> idle
```

- Invalid transitions are rejected in debug mode.
- Unit tests cover valid and invalid transitions.
- State is modeled using `sealed class`.

---

### User Story 1.4 — Collision detector

**As an app developer**, I want to choose or write a collision detector to decide which target the dragged item is over.

#### Acceptance Criteria

- `DndCollisionDetector` typedef exists.
- Built-in detectors exist:

```text
closestCenter
closestCorners
rectIntersection
pointerWithin
compose
```

- Collision detectors receive only geometry data, not `BuildContext`.
- Unit tests cover multiple rect scenarios.
- `compose` returns the first detector result that has non-empty collisions.
- Collision results are sorted by clear score/ranking.

---

### User Story 1.5 — Modifier contract

**As an app developer**, I want to restrict drag movement by axis, bounds, or grid.

#### Acceptance Criteria

- `DndModifier` exists.
- Built-in modifiers exist:

```text
RestrictToVerticalAxis
RestrictToHorizontalAxis
SnapToGrid
```

- Modifiers can be composed in order.
- Unit tests exist for each modifier.
- Modifiers do not depend on Flutter.

---

## Phase 2 — Basic Flutter Adapter

### Goal

Create `DndScope`, `DndController`, `DndDraggable`, `DndDroppable`, registry, basic measuring, and drag event lifecycle.

---

### User Story 2.1 — Basic draggable/droppable

**As a Flutter developer**, I want to wrap widgets with `DndDraggable` and `DndDroppable` so I can receive drag/drop events.

#### Acceptance Criteria

- This example works:

```dart
DndScope(
  onDragEnd: (event) {},
  child: Column(
    children: [
      DndDraggable(
        id: DndId('item'),
        child: Text('Drag me'),
      ),
      DndDroppable(
        id: DndId('target'),
        child: Text('Drop here'),
      ),
    ],
  ),
)
```

- `onDragStart` is called exactly once when drag starts.
- `onDragMove` is called when the pointer moves.
- `onDragOver` is called when the active item is over a droppable.
- `onDragEnd` is called on pointer up.
- `onDragCancel` is called on cancel.
- Widget test simulates a successful drag.

---

### User Story 2.2 — Uncontrolled controller

**As a Flutter developer**, I want to use `DndScope` without manually creating a controller.

#### Acceptance Criteria

- `DndScope(child: ...)` works.
- Internal controller is created in `initState`.
- Internal controller is disposed in `dispose`.
- No memory leak in basic widget test.
- Public API does not require `controller`.

---

### User Story 2.3 — Controlled controller

**As an advanced developer**, I want to pass a `DndController` so I can inspect or control drag state.

#### Acceptance Criteria

- `DndScope(controller: controller, child: ...)` works.
- External controller is not disposed by `DndScope`.
- User can listen to controller state.
- Controller exposes at minimum:

```text
state
active
over
cancel()
```

- Calling `controller.cancel()` during dragging triggers the cancel lifecycle.

---

### User Story 2.4 — Registry

**As a maintainer**, I want draggable and droppable entries to register/unregister safely according to widget lifecycle.

#### Acceptance Criteria

- Draggable registers when mounted.
- Droppable registers when mounted.
- Entry unregisters on dispose.
- Entry updates when widget id/data/disabled changes.
- Duplicate ID asserts in debug mode.
- Release mode does not crash unnecessarily because of duplicate ID; warning is sent through diagnostics.

---

## Phase 3 — Sensors & Activation

### Goal

Support pointer, mouse, touch, long press, and keyboard input for mobile, web, and desktop.

---

### User Story 3.1 — Pointer drag

**As a web/desktop developer**, I want to drag items using mouse/pointer input.

#### Acceptance Criteria

- Mouse primary button can start dragging.
- Right click does not start dragging by default.
- Pointer move updates drag position.
- Pointer up ends drag.
- Pointer cancel triggers cancel.
- Works on Flutter web and desktop examples.

---

### User Story 3.2 — Distance activation

**As an app developer**, I want dragging to start only after the pointer has moved a minimum distance to prevent accidental drags.

#### Acceptance Criteria

- `DndDistanceConstraint` exists.
- If movement is smaller than the distance, state remains pending.
- If movement is greater than or equal to the distance, state becomes dragging.
- Unit/widget tests cover threshold behavior.
- Default desktop/web threshold should be around 4–8 px.

---

### User Story 3.3 — Long press drag

**As a mobile developer**, I want dragging to start only after long press to avoid conflicts with scroll/tap.

#### Acceptance Criteria

- `DndLongPressSensor` or `DndLongPressConstraint` exists.
- Long press after required delay starts dragging.
- Pointer movement beyond tolerance before delay cancels pending drag.
- Pointer up before delay does not start dragging.
- Widget tests use fake async.
- `hapticFeedback` option exists.

---

### User Story 3.4 — Drag handle

**As an app developer**, I want only a small part of an item to activate dragging.

#### Acceptance Criteria

- `DndDragHandle` widget exists.
- If `DndDraggable` contains `DndDragHandle`, drag only starts from the handle.
- If no handle exists, the whole child is the activator.
- Multiple handles in one draggable are supported.
- Drag handle works with mouse, touch, and keyboard focus.
- Dedicated example exists.

---

### User Story 3.5 — Keyboard sensor

**As a keyboard user**, I want to pick up, move, drop, and cancel items using the keyboard.

#### Acceptance Criteria

- Space/Enter can pick up focused item.
- Arrow keys move the active item.
- Escape cancels.
- Space/Enter drops.
- Semantics hint exists.
- Widget tests cover keyboard flow.
- Does not crash when no droppable exists.

---

## Phase 4 — Measuring, Collision Runtime & Modifiers

### Goal

Ensure layout measuring is accurate, collision detection is stable, and drag performance remains acceptable.

---

### User Story 4.1 — Measure on drag start

**As an app developer**, I want collision detection to use the current layout accurately.

#### Acceptance Criteria

- On drag start, the library measures the active draggable and droppables.
- Rects are converted into the same coordinate space.
- Disabled droppables do not participate in collision.
- Unmounted droppables do not participate in collision.
- Widget tests cover multiple droppables.

---

### User Story 4.2 — Cached measuring

**As a maintainer**, I want to avoid measuring layout on every pointer move.

#### Acceptance Criteria

- Pointer move does not measure all droppables every time.
- Measuring cache is invalidated on scroll or layout changes.
- Collision runs on cached rects.
- Debug counter exists in test/dev mode to track measurement count.
- Collision pass runs at most once per frame.

---

### User Story 4.3 — Custom collision detector

**As an advanced developer**, I want to pass a custom collision detector for special use cases like Kanban or canvas editors.

#### Acceptance Criteria

- `DndScope(collisionDetector: customDetector)` works.
- Custom detector receives `activeRect`, `pointer`, and `droppables`.
- Custom detector may return an empty list.
- If empty list is returned, `event.over == null`.
- Custom collision example exists.

---

### User Story 4.4 — Modifiers

**As an app developer**, I want to restrict dragging by axis or grid.

#### Acceptance Criteria

- `DndScope(modifiers: [...])` works.
- Modifiers are applied in order.
- Built-in vertical/horizontal restriction works.
- Snap-to-grid works.
- Dedicated modifier example exists.
- Core unit tests and Flutter widget tests exist.

---

## Phase 5 — Drag Overlay, Visual State & Auto-scroll

### Goal

Complete the production drag/drop experience with overlay, visual state, and auto-scroll.

---

### User Story 5.1 — Drag overlay

**As an app developer**, I want to render a separate overlay widget while dragging.

#### Acceptance Criteria

- `DndDragOverlay` exists.
- Overlay follows the pointer.
- Overlay does not occupy layout space.
- Overlay does not intercept pointer by default.
- Overlay disappears after drop/cancel.
- Overlay builder receives active item data.
- Drag overlay example exists.

---

### User Story 5.2 — Draggable visual state

**As an app developer**, I want to change the UI of an item while it is being dragged.

#### Acceptance Criteria

- `DndDraggable.builder` receives state.
- State has:

```text
isDragging
isPressed
isDisabled
transform
```

- Source item can be rendered with opacity 0.4 while dragging.
- The whole `DndScope` is not rebuilt on every pointer move.
- Widget tests verify state changes.

---

### User Story 5.3 — Droppable visual state

**As an app developer**, I want to highlight a droppable when an item is hovering over it.

#### Acceptance Criteria

- `DndDroppable.builder` receives state.
- State has:

```text
isOver
isActive
canAccept
collision
```

- Droppable has `isOver == true` only when it is the current candidate.
- `accepts` callback affects `canAccept`.
- Highlight drop zone example exists.

---

### User Story 5.4 — Auto-scroll

**As an app developer**, I want scrollable containers to auto-scroll when dragging near their edges.

#### Acceptance Criteria

- `DndAutoScrollConfig.enabled()` works.
- Vertical `ListView` auto-scrolls near top/bottom.
- Horizontal scroll auto-scrolls near left/right.
- Auto-scroll stops on drop/cancel.
- Auto-scroll does not run when the pointer is not near an edge.
- Auto-scroll example exists.
- Minimal vertical auto-scroll widget/integration test exists.

---

## Phase 6 — Stable Sortable Preset

### Goal

Provide production-usable vertical list, horizontal list, and grid sorting.

---

### User Story 6.1 — Sortable vertical list

**As an app developer**, I want to create a sortable vertical list with a simple API.

#### Acceptance Criteria

- `SortableScope` + `SortableItem` works with vertical list.
- `onReorder` returns `oldIndex`, `newIndex`, and `activeId`.
- User mutates the list manually.
- Non-active items animate to projected positions.
- Dragging items up/down works reliably.
- `sortable_list` example exists.
- Widget test reorders index 0 to index 2.

---

### User Story 6.2 — Sortable horizontal list

**As an app developer**, I want to reorder items in a horizontal list.

#### Acceptance Criteria

- `horizontalList` strategy works.
- Horizontal-axis collision is accurate.
- `onReorder` returns correct indexes.
- Example exists.
- Widget test exists.

---

### User Story 6.3 — Sortable grid

**As an app developer**, I want to reorder items in a grid.

#### Acceptance Criteria

- `grid` strategy works with `GridView`.
- Dragging items across rows/columns returns correct indexes.
- Other items animate to projected positions.
- `sortable_grid` example exists.
- Widget test drags index 0 to index 5.

---

### User Story 6.4 — Sortable drag handle

**As an app developer**, I want sortable items to be draggable only from a handle.

#### Acceptance Criteria

- `SortableItem` is compatible with `DndDragHandle`.
- Dragging outside the handle does not start when a handle exists.
- Dragging from the handle starts normally.
- Example exists.

---

### User Story 6.5 — Sortable accessibility

**As a keyboard user**, I want to reorder items using the keyboard.

#### Acceptance Criteria

- Focus item.
- Space/Enter picks up.
- Arrow key changes projected index.
- Space/Enter drops.
- Escape cancels.
- `onReorder` is called correctly on drop.
- Semantics hint exists.
- Widget test covers keyboard reorder.

---

## Phase 7 — Kanban Showcase & Experimental Multi-container

### Goal

Use Kanban as a realistic showcase proving that the generic engine is powerful enough.

---

### User Story 7.1 — Kanban board demo

**As a developer evaluating the library**, I want to see a realistic Kanban board demo to understand whether the library is powerful enough.

#### Acceptance Criteria

`kanban_board` example includes:

```text
- multiple columns;
- multiple task/cards;
- dragging cards within the same column;
- dragging cards to another column;
- drag overlay;
- droppable highlight;
- vertical auto-scroll inside columns;
- horizontal auto-scroll for board;
- custom collision detector;
- source item opacity while dragging.
```

- Demo runs on web.
- Demo runs on desktop.
- Demo runs on mobile at a basic level.

---

### User Story 7.2 — Generic Kanban using DndDraggable/DndDroppable

**As an app developer**, I want to build Kanban without being forced to use `SortableScope.multi`.

#### Acceptance Criteria

- First Kanban demo uses generic APIs:

```text
DndScope
DndDraggable
DndDroppable
DndDragOverlay
```

- `onDragEnd` provides enough data for user to move tasks manually.
- `event.active.data` is the task.
- `event.over.data` is the column or target task.
- Basic demo does not require experimental API.

---

### User Story 7.3 — Experimental multi-container sortable

**As an advanced developer**, I want to try multi-container sorting for Kanban while accepting that the API is experimental.

#### Acceptance Criteria

- API is annotated with `@experimental`.
- `SortableContainer` model exists.
- `SortableMoveDetails` event exists.
- Docs clearly state that this API is not stable yet.
- Experimental example exists.
- Breaking changes to experimental API do not affect stable API.

---

## Phase 8 — Production Hardening

### Goal

Bring the package to a public, usable, production-oriented release quality.

---

### User Story 8.1 — Diagnostics

**As an app developer**, I want to know when I misconfigure the library instead of having it fail silently.

#### Acceptance Criteria

- Debug asserts for:

```text
duplicate DndId
DndDraggable outside DndScope
DndDroppable outside DndScope
SortableItem outside SortableScope
ID in SortableScope does not exist in children
```

- Release mode does not crash unnecessarily.
- `DndDiagnosticsConfig` exists.
- `onWarning` callback exists.
- Warning messages are clear and actionable.

---

### User Story 8.2 — Performance baseline

**As a maintainer**, I want benchmarks to prevent performance regressions.

#### Acceptance Criteria

- Benchmark/example with 200 visible draggable items exists.
- Dragging does not rebuild the entire app on every move.
- Collision does not run more than once per frame.
- Overlay position updates smoothly.
- Debug counters exist for:

```text
measure count
collision count
critical widget rebuild count
```

- Performance guide exists in docs.

---

### User Story 8.3 — Cross-platform verification

**As a package maintainer**, I want to ensure the package runs on mobile, web, and desktop.

#### Acceptance Criteria

- CI runs analyze/test.
- Example compiles for Android.
- Example compiles for iOS if macOS CI is available.
- Example compiles for Web.
- Example compiles for macOS/Windows/Linux at least through a local/manual checklist.
- README clearly states platform support.

---

### User Story 8.4 — Documentation

**As a new developer**, I want to read the docs and start using the library within a few minutes.

#### Acceptance Criteria

Docs include at minimum:

```text
Getting Started
Basic Draggable/Droppable
Drag Overlay
Drag Handle
Collision Detection
Modifiers
Sensors
Auto-scroll
Sortable List
Sortable Grid
Kanban Example
Accessibility
Performance Guide
Troubleshooting
Migration Guide
```

- Each docs page has a code sample.
- Code samples compile.
- README includes GIF/screenshot demo.
- API docs generate without errors.

---

# 15. Release Plan

## `0.1.0-dev`

Goal: API skeleton + core tests.

Includes:

```text
- repo setup
- dnd_kit_core
- DndId
- geometry
- state machine
- collision algorithms
- modifier contract
- initial docs
```

Not production-ready.

---

## `0.2.0-dev`

Goal: basic Flutter adapter.

Includes:

```text
- DndScope
- DndController
- DndDraggable
- DndDroppable
- pointer sensor
- basic measuring
- basic drag events
- basic example
```

---

## `0.3.0-dev`

Goal: visual state + overlay + handles.

Includes:

```text
- DndDragHandle
- DndDragOverlay
- draggable builder state
- droppable builder state
- distance activation
- long press activation
```

---

## `0.4.0-dev`

Goal: collision, modifiers, and measuring hardening.

Includes:

```text
- custom collision detector
- built-in collision detectors
- built-in modifiers
- measuring cache
- scroll/layout invalidation
```

---

## `0.5.0-dev`

Goal: sortable preset.

Includes:

```text
- SortableScope
- SortableItem
- vertical list
- horizontal list
- grid
- sortable examples
```

---

## `0.6.0-dev`

Goal: auto-scroll + keyboard.

Includes:

```text
- auto-scroll
- keyboard sensor
- semantics
- accessibility docs
```

---

## `0.7.0-dev`

Goal: Kanban showcase.

Includes:

```text
- Kanban example
- custom collision example
- experimental multi-container model
```

---

## `1.0.0`

Release only when:

```text
- stable API list is frozen
- core test coverage is solid
- examples run correctly
- docs are good enough for public usage
- no known critical bugs remain
- performance baseline is acceptable
- breaking API has been reviewed carefully
```

---

# 16. Stable vs Experimental API

## Stable from `1.0.0`

```text
DndId
DndPoint
DndSize
DndRect
DndTransform

DndScope
DndController
DndDraggable
DndDroppable
DndDragHandle
DndDragOverlay

DndCollisionDetector
DndCollisionDetectors
DndModifier
DndSensor
DndActivationConstraint

DndDragStartEvent
DndDragMoveEvent
DndDragOverEvent
DndDragEndEvent
DndDragCancelEvent

SortableScope
SortableItem
SortableStrategies.verticalList
SortableStrategies.horizontalList
SortableStrategies.grid
```

---

## Experimental in `1.0.0`

```text
SortableScope.multi
SortableContainer
VirtualSortableAdapter
NestedSortableScope
Debug visualizer
Devtools overlay
```

---

# 17. Quality Gates

Before publishing any package:

```text
dart format .
dart analyze
dart test
flutter test
melos run test
melos run analyze
melos run example:build:web
```

Before `1.0.0`:

```text
- No public API is missing dartdoc.
- No example has analyze errors.
- No TODO remains in stable API.
- No experimental API is exported as stable without @experimental.
- No unnecessary dependency is included.
- CHANGELOG is complete.
- README includes basic API usage and links to docs.
```

---

# 18. Main Technical Risks

## 18.1 Incorrect coordinate-space measuring

This is one of the biggest risks.

Mitigation:

```text
- normalize all rects into global coordinates;
- test with nested Transform/ScrollView;
- provide debug overlay for rect visualization;
- never mix local/global coordinates during collision.
```

---

## 18.2 Gesture conflict with scroll

Especially important on mobile.

Mitigation:

```text
- use long press by default for touch;
- use distance constraint for mouse/pointer;
- support drag handles;
- use activation tolerance;
- avoid claiming gestures too early.
```

---

## 18.3 Too many rebuilds during drag

Mitigation:

```text
- use controller/listenable instead of setState on the whole scope;
- update overlay independently;
- let individual draggable/droppable widgets subscribe to their own state;
- throttle collision to frame boundaries.
```

---

## 18.4 Sortable grid is more complex than list

Mitigation:

```text
- implement vertical/horizontal list first;
- stabilize grid strategy only after enough tests;
- do not support masonry as stable in v1.
```

---

## 18.5 Multi-container API may break future API

Mitigation:

```text
- design events with from/to container fields from the beginning;
- keep multi-container API experimental;
- first Kanban demo should use generic DndDraggable/DndDroppable.
```

---

# 19. Definition of Done for Production v1

`dnd_kit` is considered production-ready v1 when:

```text
- Basic drag/drop works reliably on mobile/web/desktop.
- Drag overlay is stable.
- Custom collision detector works.
- Modifiers work.
- Auto-scroll works for common cases.
- Sortable vertical list is stable.
- Sortable horizontal list is stable.
- Sortable grid is stable.
- Basic keyboard accessibility flow exists.
- Kanban demo works.
- Docs are sufficient for users to adopt the library.
- Stable API is clearly documented.
- Experimental API is clearly marked.
- Core logic has meaningful test coverage.
- No external state management dependency is used.
```

---

# 20. Final Design Direction

The best architecture for this library is:

```text
Generic DnD engine first
Flutter adapter second
Sortable as preset
Kanban as showcase
Multi-container as experimental
Native OS drag/drop as future package
```

With this design, `dnd_kit` will not merely become a better `ReorderableListView`. It can become a **foundation package** for complex Flutter UIs, especially web/desktop admin tools, Kanban boards, builders/editors, dashboards, and drag-heavy productivity apps.
