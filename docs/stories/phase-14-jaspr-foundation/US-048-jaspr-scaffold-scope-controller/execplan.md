# Exec Plan

## Goal

Stand up the `dnd_kit_jaspr` package with a `DndScope` + `DndController`
foundation over the shared `DndRuntime`, so later stories can add components
without re-deciding package structure, the controller/notify model, or the SSR
posture.

## Scope

In scope:

- Create `packages/dnd_kit_jaspr` (pubspec: `dnd_kit_core: ^0.1.0`, `jaspr: any`;
  dev: `jaspr_test`, `test`, `lints`). Add to the Melos workspace.
- `dnd_kit_jaspr.dart` barrel re-exporting `dnd_kit_core` + the Jaspr surface.
- `DndController` wrapping `DndRuntime` with a Jaspr-friendly listenable.
- `DndScope` (`StatefulComponent` owning the controller + `InheritedComponent`
  for propagation) and `DndScope.of(context)`.
- Pure-Dart + `jaspr_test` proof; no browser interaction yet.
- Update `docs/ARCHITECTURE.md` package layer diagram + dependency table.

Out of scope:

- All draggable/droppable/handle/overlay components and sensors (US-049+).
- DOM measuring, collision-while-scrolling, auto-scroll execution.
- Sortable presets.

## Risk Classification

Risk flags:

- Public contracts (new published package + public surface).
- Cross-platform (browser adapter, SSR/hydration posture).
- New initiative (first of a multi-story area).

Hard gates:

- None. New-initiative + public-contract ⇒ high-risk lane for the scaffold so
  structure and SSR posture are reviewed before components depend on them.

## Work Phases

1. Discovery — Jaspr component/event/element + SSR/hydration model reviewed via
   the jaspr-fundamentals and jaspr-pre-rendering skills. Done.
2. Design — see `design.md` (controller notify model, scope plumbing, SSR posture).
3. Validation planning — see `validation.md`.
4. Implementation — package + barrel; `DndController`; `DndScope` + `of`.
5. Verification — `dart pub get`, `dart analyze`, `dart test` (incl. jaspr_test);
   confirm no Flutter dependency and no server-unsafe imports in shared code.
6. Harness update — record proof + evidence; cross-link ADR 0016.

## Subsequent Phase B stories (planned, not this story)

1. US-049 `DndDraggable` + pointer sensor activation + DOM measuring (decide the
   deferred `DndPointerSensor` sharing here).
2. US-050 `DndDroppable` + collision runtime wiring.
3. US-051 `DndDragHandle` + mouse/touch/keyboard activation kinds.
4. US-052 `DndDragOverlay` via top-level/portal DOM layer.
5. US-053 modifiers wiring + `jaspr_basic_drag_drop` example + chrome-devtools
   browser proof.

## Stop Conditions

Pause for human confirmation if:

- The controller notify model would require changes to `dnd_kit_core`.
- A Jaspr API forces a structure that diverges from the Flutter mental model.
- The package cannot stay importable in server/static mode without leaking
  `dart:js_interop` / `package:web`.
