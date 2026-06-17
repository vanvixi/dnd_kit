# Product Overview

## Summary

`dnd_kit` is a drag-and-drop toolkit family centered on a pure Dart engine
(`dnd_kit`) with adapter packages for Flutter (`dnd_kit_flutter`) and
Jaspr/browser (`dnd_kit_jaspr`).

The project takes inspiration from React dnd-kit, but each adapter uses
framework-native concepts while sharing one domain model, drag lifecycle,
collision/modifier logic, diagnostics posture, and as much runtime code as can
stay framework-agnostic.

## Goals

- Provide a generic draggable and droppable engine before presets.
- Keep one shared engine contract and treat framework packages as peer adapters
  over that engine.
- Offer family-consistent APIs such as `DndScope`, `DndDraggable`,
  `DndDroppable`, and `DndDragOverlay`, while letting each adapter stay native
  to its framework.
- Keep user data ownership outside the library.
- Support mobile, web, and desktop as first-class targets through the adapter
  family.
- Keep the core package pure Dart and independently testable.
- Allow custom sensors, collision detectors, modifiers, measuring strategies,
  drag overlays, and sortable strategies.
- Stabilize core public API early enough to avoid avoidable breaking changes.

## Non-Goals For Stable V1

- Native OS-level file drag and drop.
- Cross-window or cross-app drag and drop.
- Full virtualized variable-height sortable lists.
- Complex nested sortable layouts.
- Highly opinionated animation systems.
- Dependency on Riverpod, Provider, BLoC, Redux, or another external state
  management library.

Native OS drag and drop can be explored later in a separate package named
`dnd_kit_native`.

## Target Users

- Flutter application developers building sortable, canvas, builder, board, or
  dashboard interfaces.
- Jaspr developers building browser drag-and-drop interfaces over the shared
  engine.
- Maintainers who need a reusable, testable, type-safe drag-and-drop foundation.
- Advanced developers who want the pure Dart collision, modifier, or sortable
  math without either adapter.

## Source

Derived from `SPEC.md` v0.1 and `SPEC_JASPR.md` v0.1.

Those specs are retained as historical input material. The living source of
truth for implementation work is this product-doc set together with the story
packets, validation proof, and decision records under `docs/`.
