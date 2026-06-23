# Design

## Domain Model

The engine owns the portable experimental contract:

- `SortableContainer`: immutable container metadata (`id`, ordered `itemIds`,
  `indexOf`, `contains`).
- `SortableMultiContainer.moveDetailsFor(...)`: pure-Dart helper that converts
  a `DndDragEndEvent` plus application-owned container snapshots into a
  `SortableMoveDetails` intent.
- existing `SortableMoveDetails`, `DndId`, and geometry/session types remain
  unchanged and stay in `dnd_kit`.

The contract remains explicitly `@experimental`. Applications continue to own
all actual container and item mutation after the library reports move intent.

Adapter-local scope data stays where it is today:

- Flutter and Jaspr keep their own `SortableScopeData` plumbing because it is
  part of their widget/component-layer lookup model.
- No Flutter, Jaspr, DOM, or render/component type crosses into the engine.

## Application Flow

1. An application renders one sortable scope per container with its own
   `containerId`.
2. On drag end, the adapter still reports the shared `DndDragEndEvent`.
3. The application assembles its current container snapshots as
   `Iterable<SortableContainer>`.
4. The shared helper `SortableMultiContainer.moveDetailsFor(...)` computes the
   cross-container or same-container move intent.
5. The application mutates its own state from the returned
   `SortableMoveDetails`.

This preserves the current Flutter mental model and gives Jaspr the same move
intent path without a second helper implementation.

## Interface Contract

Public surface changes are additive and compatibility-first:

- `dnd_kit` exports the experimental multi-container helper file.
- `dnd_kit_flutter` keeps exporting `SortableContainer` and
  `SortableMultiContainer` from its current barrel; its adapter-local source
  becomes a compatibility re-export of the engine symbols.
- `dnd_kit_jaspr` exports the same shared helper symbols from its barrel.

No stable sortable API is removed. Existing Flutter consumers may keep their
current imports, while new cross-adapter consumers can import the shared types
directly from `package:dnd_kit/dnd_kit.dart`.

## Data Model

No persisted product data changes. Durable Harness state adds:

- one intake row for the story-selection request;
- one story row for `US-076`;
- one detailed trace describing the packet creation work.

## UI / Platform Impact

The runtime behavior impact is cross-adapter parity rather than new visuals:

- Flutter keeps its existing experimental demo and moves to the shared helper
  source without behavior drift.
- Jaspr gains a supported path for multi-container move intent and should add
  at least one browser-visible proof surface.
- SSR safety remains unchanged because the moved helper code is pure Dart and
  does not touch DOM APIs.

## Observability

Proof should make the shared contract obvious:

- core unit tests become the source of truth for the helper semantics;
- adapter tests prove barrel reachability and compatibility re-exports;
- example/browser proof demonstrates parity on real drag flows.

## Alternatives Considered

1. Duplicate the Flutter helper code into `dnd_kit_jaspr`.
   Rejected because the helpers are already pure Dart and duplication would
   reopen the exact parity and drift problem that the shared engine exists to
   prevent.
2. Hoist both `SortableScopeData` implementations into the engine at the same
   time.
   Deferred because the scope-data plumbing is still adapter-local and ADR 0019
   already accepted that duplication as the smaller boundary tradeoff.
3. Stabilize the multi-container API as part of the hoist.
   Rejected because the current contract is still intentionally experimental and
   should gain cross-adapter proof before any stabilization decision.
