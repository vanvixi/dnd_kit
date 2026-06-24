# 0022 Production-Ready Multi-Container Surface

Date: 2026-06-24

## Status

Accepted

## Context

ADR 0021 moved `SortableContainer` and `SortableMultiContainer` into
`dnd_kit`, but that left multi-container in a helper-only state:

- applications still had to combine raw `DndDroppable` wiring, a custom
  collision detector, and app-side `onDragEnd` resolution;
- the Flutter example still used a two-phase cross-container update workaround;
- Jaspr had parity with the helper contract but no first-class adapter-level
  surface;
- docs still described the feature as experimental helper parity rather than a
  supported board/list capability.

Phase 29 needed one durable answer to these questions:

1. Which layer owns default multi-container interaction semantics?
2. How do Flutter and Jaspr expose that behavior without forking the logic?
3. Which responsibilities remain application-owned?

## Decision

1. **`dnd_kit` owns the default pure-Dart multi-container semantics.**
   `SortableMultiContainer` now defines the default collision detector plus the
   move-intent resolution policy for common board/list flows, including
   item-vs-container target resolution, empty-container insertion, and
   before/after over-item insertion.
2. **Flutter and Jaspr expose first-class multi-container adapter surfaces.**
   Both adapters now provide:
   - `SortableMultiScope`
   - `SortableMultiContainerArea`
   - `SortableMultiItem`

   These surfaces wire default collision ranking and drag-end move resolution
   so applications no longer need to hand-assemble the low-level pieces for
   the supported case.
3. **Applications keep ownership of presentation and mutation.**
   The library reports `SortableMoveDetails`; applications still render their
   own UI and commit their own state changes.
4. **Override hooks stay explicit and additive.**
   Products can override default behavior through:
   - `SortableMultiScope.collisionDetector`
   - `SortableMultiScope.moveResolver`
   - `SortableMultiInsertionStrategy`
5. **The supported scope is the common board/list case.**
   Nested sortable trees, virtualization policy, and app-specific visual
   systems remain outside this slice.

## Alternatives Considered

1. Keep multi-container as a helper-only contract.
   Rejected: it preserves example-owned behavior and avoids library ownership
   of a supported interaction contract.
2. Put the default policy only in adapter code.
   Rejected: Flutter and Jaspr would drift even though the behavior is pure
   Dart.
3. Make the library mutate user-owned collections directly.
   Rejected: it violates the project rule that applications own their data and
   state transitions.

## Consequences

Positive:

- Multi-container is now a supported library feature rather than only a helper.
- Flutter and Jaspr share one source of truth for default board/list semantics.
- Applications can adopt the common case with much less custom wiring.

Tradeoffs:

- The shared core surface grows with more multi-container policy API.
- Controlled scopes that inject their own controller must still choose whether
  to keep the library default collision detector or provide a custom one.
- Advanced drag domains still need future follow-up stories.

## Follow-Up

- Add a gallery-grade Jaspr multi-container demo when Phase 29 expands beyond
  the initial production-ready slice.
- Revisit virtualized and nested multi-container behavior in later stories
  instead of broadening this contract implicitly.
