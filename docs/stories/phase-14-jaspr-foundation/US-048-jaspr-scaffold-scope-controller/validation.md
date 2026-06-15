# Validation

## Proof Strategy

The scaffold is proven when the package resolves with no Flutter dependency, the
Jaspr `DndController` drives the shared `DndRuntime` identically to the Flutter
controller, and `DndScope` provides the controller to descendants — verified by
pure-Dart tests and `jaspr_test` component tests, with no browser interaction
required yet.

## Test Plan

| Layer | Cases |
| --- | --- |
| Unit | Jaspr `DndController`: starts idle; `beginDrag`→`startDrag`→`moveDrag`→`endDrag`→`reset` drives runtime state; listeners fire on each transition (notify-count parity with the core `DndRuntime` test); duplicate-id diagnostics surface via the shared registry. |
| Integration | `jaspr_test`: a `DndScope` renders its child and `DndScope.of(context)` returns the owned controller; an injected controller is used instead of a created one; the created controller is disposed when the scope unmounts. |
| E2E | Deferred to US-049+ (browser pointer drag via chrome-devtools MCP). |
| Platform | `dart pub get` resolves; `dart analyze` clean; package has no Flutter dependency; shared code imports no `dart:js_interop`/`package:web` at top level (importable from a server entrypoint). |
| Performance | N/A. |
| Logs/Audit | Duplicate-id diagnostic warning observed in a controller test. |

## Fixtures

- Deterministic `DndId`/`DndPoint`/`DndRect` literals (reused from the core
  runtime tests).
- A listener counter closure to assert notification parity.
- A `jaspr_test` harness rendering `DndScope(child: ...)`.

## Commands

```text
fvm dart pub get
fvm dart analyze packages/dnd_kit_jaspr
fvm dart test packages/dnd_kit_jaspr
```

## Acceptance Evidence

Verified 2026-06-15 (fvm Dart 3.10.4):

- `fvm dart pub get` resolves the workspace with `dnd_kit_jaspr` added; its
  dependency subtree is `dnd_kit_core` + `jaspr` only (jaspr pulls pure-Dart
  deps). No Flutter under `dnd_kit_jaspr`.
- `fvm dart analyze packages/dnd_kit_jaspr` → **No issues found**.
- `fvm dart test packages/dnd_kit_jaspr` → **5 passed**: 3 `DndController`
  (idle start; begin→start→move→end→reset drives the runtime with notify-count 5;
  duplicate-id diagnostics via the shared registry) + 2 `DndScope` (`jaspr_test`:
  provides a created controller via `DndScope.of`; uses an injected controller).
- `fvm dart format --set-exit-if-changed --line-length 100` → clean.
- Decision: Jaspr ships `ChangeNotifier`, so `DndController extends
  ChangeNotifier` with `onNotify: notifyListeners` — mirroring Flutter (the
  design's notify-model open choice resolved to the listener-list option via
  Jaspr's own `ChangeNotifier`). Registry deferral uses `scheduleMicrotask`.
