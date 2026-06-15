# Overview

## Current Behavior

There is no Jaspr adapter. The shared engine (`DndRuntime`, measuring, collision,
modifiers, sortable math, auto-scroll math) lives in `dnd_kit_core` after Phase 13
(US-047), and `dnd_kit_flutter` wraps it as `DndController extends ChangeNotifier`.
Nothing yet lets a Jaspr/browser app consume the engine.

## Target Behavior

A new pure-Jaspr package `dnd_kit_jaspr` exists and provides the foundation that
every later Jaspr drag/drop component builds on:

- `dnd_kit_jaspr` depends only on `dnd_kit_core` and `jaspr` (no Flutter, no
  `dnd_kit` umbrella).
- `DndController` is a thin Jaspr wrapper over the shared `DndRuntime`, exposing
  a listenable so components rebuild on drag-state changes.
- `DndScope` owns a controller's lifecycle and provides it to descendants via an
  `InheritedComponent`, with `DndScope.of(context)` lookup — mirroring the
  Flutter mental model.
- The package is safe to import in any Jaspr mode (client/server/static): DOM
  access goes through `package:universal_web` guarded by `kIsWeb`, and
  interactive drag wiring runs under `@client` hydration in apps.

This is the walking skeleton: no visible drag yet, but the package resolves, the
controller drives the shared runtime, and the scope provides it. Draggable,
droppable, sensors, measuring, overlay, and examples follow in US-049+.

## Affected Users

- Jaspr app developers (gain the entry-point package and scope/controller).
- Library maintainers (establishes the adapter's structure and SSR posture).

## Affected Product Docs

- `SPEC_JASPR.md` §3.3, §5, §6, §9 Phase B
- `docs/ARCHITECTURE.md`
- `docs/decisions/0016-jaspr-adapter-scope-and-runtime-model.md`

## Non-Goals

- `DndDraggable`, `DndDroppable`, `DndDragHandle`, drag overlay (US-049+).
- Pointer/touch/keyboard sensor implementations beyond the scope's plumbing.
- DOM measuring, collision-while-scrolling, auto-scroll execution.
- Sortable presets (Phase D).
- Any change to `dnd_kit_core` or `dnd_kit_flutter` behavior.
