# Design

## Shared Pointer Sensor

`DndPointerSensor` moves to `dnd_kit_core/lib/src/pointer_sensor.dart` unchanged
except that it is driven by a `DndRuntime` (field `runtime`) instead of a Flutter
`DndController`. It calls `runtime.isIdle/beginDrag/startDrag/moveDrag/endDrag/
cancelDrag/reset` — all of which exist on the shared runtime. The
pending → timer(delay) → movement-tolerance → start state machine and the
`DndSensorDescriptor` (pointer/mouse/touch accept, keyboard reject) are identical.

Both controllers expose `DndRuntime get runtime`. Adapters construct the sensor
with `DndPointerSensor(runtime: controller.runtime, ...)`. Flutter re-exports the
class from core; its `DndDraggable` is updated to the new constructor. This is a
breaking change to the Flutter `DndPointerSensor` constructor only
(`controller:` → `runtime:`), noted in the Flutter CHANGELOG.

## Jaspr DndDraggable

File: `dnd_kit_jaspr/lib/src/widgets/draggable.dart`. A `StatefulComponent`.

Registration:

- In `didChangeDependencies`, resolves `DndScope.of(context)` and registers a
  `DndDraggableRegistration(id, disabled, data)` with owner = the State.
- Re-registers on relevant component updates; unregisters in `dispose`.

Input (SSR-safe, no document listeners, no `dart:js_interop`):

- The element carries a `GlobalNodeKey<web.HTMLElement>` and element-level
  `pointerdown/pointermove/pointerup/pointercancel` handlers via Jaspr's
  `events:` map (Jaspr owns the listener wiring).
- On `pointerdown`: `setPointerCapture(pointerId)` so subsequent pointer events
  target this element even outside its bounds, then measure and start the sensor.
- `pointermove/up/cancel` drive `sensor.move/end/cancel`.

Measuring:

- `_nodeKey.currentNode!.getBoundingClientRect()` → `DndRect` in viewport
  coordinates, used as the sensor's `activeRect`.

Visual follow (interim, until the overlay story):

- On `onDragMove`, set `node.style.transform = 'translate(dx, dy)'` from the
  event transform; reset to `''` when the gesture ends.

SSR safety:

- Imports `package:universal_web/web.dart` (SSR-safe) — never `package:web` or
  `dart:js_interop` directly. Every DOM call is guarded by `kIsWeb` (false on the
  VM/server and in `dart test`), so registration works in `jaspr_test` while DOM
  work is skipped.

## Pointer coordinates and input kind

`PointerEvent.clientX/clientY` (int) → `DndPoint` via `.toDouble()`.
`pointerType` maps `mouse`→mouse, `touch`/`pen`→touch, else→pointer.

## Alternatives Considered

1. Document-level `pointermove/up` via `addEventListener` — rejected: needs a JS
   callback (`dart:js_interop`), which breaks SSR-import safety. Pointer capture +
   element events achieves the same without leaving the element's event wiring.
2. `EventStreamProvider` streams — not available from `package:web` on the client
   (only universal_web's server fallback), so not usable here.
3. Keep a separate Jaspr sensor — rejected: duplicates the state machine.
