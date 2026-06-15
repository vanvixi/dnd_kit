# Design

## Domain Model

No new domain model. `dnd_kit_jaspr` consumes the shared `dnd_kit_core` types
(`DndRuntime`, `DndState`, `DndId`, geometry, events, collision, modifiers,
measuring, sortable, auto-scroll) unchanged.

## Package Structure

```text
packages/dnd_kit_jaspr/
  pubspec.yaml            # dnd_kit_core ^0.1.0, jaspr: any; dev: jaspr_test, test, lints
  lib/
    dnd_kit_jaspr.dart    # barrel: export dnd_kit_core + the Jaspr surface
    src/
      scope/
        controller.dart   # DndController over DndRuntime
        scope.dart        # DndScope + DndScope.of
  test/
    src/scope/controller_test.dart
    src/scope/scope_test.dart
```

Dependency rule (extends `docs/ARCHITECTURE.md`):

| Package | May depend on | Must not depend on |
| --- | --- | --- |
| `dnd_kit_jaspr` | `dnd_kit_core`, `jaspr`, `universal_web`, `meta` | Flutter, `dart:ui`, the `dnd_kit` umbrella |

## Application Flow

### DndController (Jaspr)

A thin wrapper over `DndRuntime`, parallel to the Flutter `DndController` but
using a Jaspr-friendly change-notification instead of `ChangeNotifier`:

```dart
class DndController {
  DndController({ initialState, collisionDetector, modifiers, diagnosticsConfig }) {
    _runtime = DndRuntime(
      ...,
      onNotify: _notifyListeners,
      // browser deferral: scheduleDeferredTask via a microtask/animation frame
      scheduleDeferredTask: (task) => scheduleMicrotask(task),
    );
  }
  // forwards beginDrag/startDrag/moveDrag/endDrag/cancelDrag/reset and the
  // state/overId/activeRect/registry/measuring/... getters to _runtime
  // exposes addListener/removeListener (or a Listenable) for components
}
```

Notify model decision: Jaspr has no `ChangeNotifier`. Two candidates —
(a) a minimal listener list (`addListener`/`removeListener` + `_notifyListeners`)
that components subscribe to in `initState` and trigger `setState`, or
(b) reuse a Jaspr-provided `Listenable`/`ValueNotifier` if available in 0.23.x.
This story will pick (a) unless a stable Jaspr listenable exists, keeping the
controller framework-light and identical in spirit to Flutter. `setState`-based
rebuilds stay in the components (US-049+), not the controller.

`scheduleDeferredTask` (used by the registry's duplicate-id diagnostics) maps to
`scheduleMicrotask` in the browser, mirroring Flutter's post-frame deferral.

### DndScope

```dart
class DndScope extends StatefulComponent {
  const DndScope({ this.controller, required this.child, ... });
  // State: creates/owns a DndController if none injected; disposes it.
  // build(): returns _DndScopeProvider(controller: ..., child: child)
}

class _DndScopeProvider extends InheritedComponent { ... }

extension DndScopeContext on BuildContext {
  static DndController of(BuildContext context) => ...; // dependOnInheritedComponentOfExactType
}
```

`DndScope.of(context)` resolves the nearest controller, mirroring the Flutter
adapter so the same mental model and lookups apply.

## Interface Contract

Public surface introduced: `DndController`, `DndScope`, `DndScope.of`. Callback
payloads (`DndDragStartEvent`, `DndDragMoveEvent`, `DndDragEndEvent`,
`DndDragCancelEvent`) are the shared core types, so business logic stays portable
between Flutter and Jaspr (SPEC_JASPR §4.2).

## Data Model

None. No persistence.

## UI / Platform Impact

- The package is a library, not an app; it declares no Jaspr `mode` and no
  entrypoints. Consuming apps own the mode and `@client` annotations.
- SSR/static safety: shared code uses `package:universal_web` behind `kIsWeb`
  guards and must not import `dart:js_interop` / `package:web` at top level, so
  the package is importable from a server entrypoint. Actual pointer/DOM wiring
  (US-049+) runs only in the browser under `@client` hydration.
- This story has no DOM access yet, so the constraint is structural: keep the
  scope/controller free of browser imports.

## Observability

Duplicate-id diagnostics come from the shared registry inside `DndRuntime` and
fire identically; deferral uses `scheduleMicrotask`. No new logging.

## Alternatives Considered

1. Native HTML Drag-and-Drop API — rejected by SPEC_JASPR §6.1 (poor fit,
   browser-inconsistent, less shared logic). Custom pointer runtime instead.
2. Re-implement a Jaspr controller from scratch — rejected; wrap the shared
   `DndRuntime` to avoid a second engine (ADR 0015).
3. Force `@client` inside the library's scope component — rejected; libraries
   should not dictate the host app's hydration boundary. Apps annotate usage;
   the example (US-053) demonstrates it.
