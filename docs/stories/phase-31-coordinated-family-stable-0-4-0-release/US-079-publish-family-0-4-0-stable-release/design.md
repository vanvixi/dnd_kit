# Design

## Domain Model

The release unit is the same three-package family already established by the
post-US-060 topology:

- `dnd_kit`: pure Dart engine and dependency root.
- `dnd_kit_flutter`: Flutter adapter that depends on `dnd_kit`.
- `dnd_kit_jaspr`: Jaspr adapter that depends on `dnd_kit`.

This story closes the prepared `0.4.0-dev.1` line as one coordinated stable
publish act so dependency constraints, changelog truth, and release proof stay
aligned.

## Application Flow

1. Confirm the repository package metadata and changelogs align on `0.4.0`
   stable.
2. Run `dart pub get` and the shared family validation command.
3. Run package publish dry-runs in dependency order through the verifier.
4. Record the exact publish order and the remaining maintainer-run irreversible
   step.

## Interface Contract

No new public API is introduced by this story. The published contracts are the
already-landed `0.4.0-dev.*` deltas:

- `dnd_kit` exports the shared multi-container helper contract plus the
  production-ready default move policy.
- `dnd_kit_flutter` exports `SortableMultiScope`,
  `SortableMultiContainerArea`, and `SortableMultiItem` as the supported
  Flutter multi-container surface.
- `dnd_kit_jaspr` exports `SortableMultiScope`,
  `SortableMultiContainerArea`, and `SortableMultiItem` as the supported
  Jaspr/browser multi-container surface.

The release contract is therefore versioning and proof, not new behavior.

## Data Model

No application data model changes. Durable Harness state adds an intake row, a
story row, and a trace for the coordinated release packet.

## UI / Platform Impact

Platform impact is consumer-facing through package publication:

- Pure-Dart consumers receive the stable shared multi-container contract in
  `dnd_kit 0.4.0`.
- Flutter consumers receive the supported multi-container adapter surface in
  `dnd_kit_flutter 0.4.0`.
- Jaspr consumers receive the matching supported multi-container adapter
  surface in `dnd_kit_jaspr 0.4.0`.

The Phase 30 website adoption remains product proof and release context, but it
does not introduce extra package API scope beyond the stable family line.

## Observability

Proof is release-oriented:

- shared family verification via `fvm dart run tool/verify_family_release.dart`;
- package dry-run output in dependency order;
- Harness intake/story/trace records capturing versions, publish order, and any
  blocker.

## Alternatives Considered

1. Hold the prepared dev line for another feature wave.
   Rejected because the repository already published `0.4.0-dev.1` as a
   coordinated family line and the next safe step is to close that line as
   stable once proof is refreshed.
2. Publish only `dnd_kit` and `dnd_kit_flutter`.
   Rejected because the repository already positioned the family as a
   coordinated shared-engine release line, and `dnd_kit_jaspr` ships the same
   supported multi-container surface on `^0.4.0-dev.1`.
3. Skip a stable `0.4.0` line and continue directly to `0.5.0-dev`.
   Rejected because it would leave the production-ready multi-container
   milestone without a stable family publication.
