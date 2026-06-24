# Design

## Domain Model

The production-ready multi-container feature separates three concerns:

1. **Interaction policy** — library-owned default behavior semantics:
   - how to resolve the active target when item and container candidates
     compete;
   - how to choose insertion position before/after an item;
   - how to treat empty containers and container-edge drops;
   - how to map collisions into move intent.
2. **Presentation** — application-owned rendering:
   - card visuals;
   - spacing;
   - typography;
   - animation and motion flavor;
   - board/container layout.
3. **State mutation** — application-owned data updates:
   - the library reports intent;
   - the application commits the collection change.

The feature should preserve this separation explicitly: the library owns
default behavior semantics, not product styling.

## Application Flow

Target production flow:

1. The app configures a multi-container surface through adapter-level library
   APIs.
2. The library registers container and item metadata, executes the default
   policy, and computes move intent for cross-container and same-container
   drops.
3. The app receives a stable move-intent callback and mutates its own state.
4. If the app needs non-default behavior, it overrides the interaction policy
   through explicit hooks without replacing the whole multi-container stack.

This should remove the need for each app to hand-build:

- raw collision ranking;
- insertion heuristics;
- two-phase cross-container commit workarounds for the common case.

## Interface Contract

The final names remain open to implementation validation, but the supported
surface should include:

- an adapter-level multi-container scope/container/item contract for Flutter
  and Jaspr;
- a documented default policy surface owned by the library;
- explicit override hooks for products that need custom target resolution or
  insertion semantics;
- unchanged app ownership of rendering and mutation callbacks.

The contract should not require applications to import low-level helper types
unless they are intentionally opting into advanced customization.

## Data Model

No persisted application data changes. Harness state for this story should add:

- one high-risk story row;
- one durable ADR for the production-ready behavior contract;
- proof and trace updates once implementation exists.

## UI / Platform Impact

Platform impact is behavioral, not stylistic:

- Flutter and Jaspr should match on default drag/drop meaning.
- Apps should remain free to render different visuals and motion systems.
- Production examples should demonstrate supported defaults and at least one
  override scenario.

## Observability

The feature should be observable through:

- adapter tests that assert default policy semantics;
- example/browser proof for realistic cross-container drag flows;
- explicit regression coverage for empty containers, ambiguous targets, and
  override hooks.

## Alternatives Considered

1. Leave multi-container as helper-only and let every app assemble semantics.
   Rejected because it keeps the library from owning a consistent supported
   behavior contract.
2. Hard-code one visual/UX implementation inside the library.
   Rejected because presentation belongs to apps, not the drag contract.
3. Expose only low-level hooks with no default policy.
   Rejected because it still forces every app to rebuild the common behavior
   stack and does not make the feature production-ready.
