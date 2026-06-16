# Validation

## Proof Strategy

Prove the shared sensor still drives a runtime through the full lifecycle (pure
Dart), and that the Jaspr `DndDraggable` registers/unregisters with the
controller across mount/unmount. DOM measuring and real pointer behavior are
browser-dependent and are proven in US-053 with the example app and the
chrome-devtools MCP; here they are structurally correct and `kIsWeb`-guarded.

## Test Plan

| Layer | Cases |
| --- | --- |
| Unit | Core `DndPointerSensor` (on `DndRuntime`): implements the sensor contract + descriptor accept/reject; drives start/move/end; preserves input kind; cancels pending activation. |
| Integration | `jaspr_test` `DndDraggable`: registers its id/data with the controller while mounted; unregisters when removed from the tree (toggled via a button click that triggers reconciliation/dispose). |
| E2E | Deferred to US-053 (chrome-devtools: real pointer drag, measuring, transform follow). |
| Platform | `dart analyze` clean across core/flutter/jaspr; Flutter suite still green after rewiring to the shared sensor; `dnd_kit_jaspr` adds `universal_web` and stays Flutter-free. |
| Performance | N/A. |
| Logs/Audit | Duplicate-id diagnostics unaffected (shared registry). |

## Fixtures

- Deterministic `DndId`/`DndPoint`/`DndRect` literals.
- A `_Toggle` `jaspr_test` component that removes the draggable on button click.

## Commands

```text
fvm dart test packages/dnd_kit_core
fvm dart test packages/dnd_kit_jaspr
fvm flutter test packages/dnd_kit_flutter
fvm dart analyze packages/dnd_kit_core packages/dnd_kit_flutter packages/dnd_kit_jaspr
```

## Acceptance Evidence

Verified 2026-06-16 (fvm Dart 3.10.4 / Flutter 3.38.5):

- `dart test packages/dnd_kit_core` → **112 passed** (incl. 4 `DndPointerSensor`
  contract tests now on `DndRuntime`, moved from the Flutter adapter).
- `dart test packages/dnd_kit_jaspr` → **7 passed** (3 controller + 2 scope +
  2 `DndDraggable` register/unregister).
- `flutter test packages/dnd_kit_flutter` → **96 passed** (rewired to the shared
  sensor; the 4 sensor unit tests moved to core).
- `dart analyze` → **No issues found** in all three packages.
- Flutter `DndPointerSensor` constructor change (`controller:` → `runtime:`)
  recorded under the Flutter CHANGELOG "Unreleased" section; class still
  importable from `package:dnd_kit_flutter/dnd_kit_flutter.dart`.
