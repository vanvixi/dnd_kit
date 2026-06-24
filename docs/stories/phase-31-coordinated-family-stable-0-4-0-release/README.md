# Phase 31 - Coordinated Family Stable 0.4.0 Release

Phase 29 graduated multi-container into a supported cross-adapter feature, and
Phase 30 moved the hosted Jaspr homepage onto that supported surface. The
package family already published the coordinated `0.4.0-dev.1` line on
2026-06-24, but the next stable family release packet had not yet been
prepared.

This phase closes that gap by promoting the current dev line to a coordinated
stable `0.4.0` release:

- `dnd_kit 0.4.0` publishes the shared multi-container contract and the
  production-ready default move policy;
- `dnd_kit_flutter 0.4.0` publishes the supported multi-container adapter
  surface for Flutter;
- `dnd_kit_jaspr 0.4.0` publishes the matching supported multi-container
  adapter surface for Jaspr/browser;
- the release packet keeps package metadata, changelog truth, and publish order
  auditable in one place.

`US-079` completed on 2026-06-24. The family published to pub.dev in strict
dependency order: `dnd_kit 0.4.0` -> `dnd_kit_flutter 0.4.0` ->
`dnd_kit_jaspr 0.4.0`.

## Principle

Release work in this phase must:

- publish in dependency order: `dnd_kit` -> `dnd_kit_flutter` ->
  `dnd_kit_jaspr`;
- keep the package scope limited to the already-landed `0.4.0-dev.*`
  multi-container deltas;
- prove the release locally with workspace validation plus package dry-runs
  before any irreversible pub.dev publish;
- record the exact stable version line, proof commands, and any remaining
  maintainer-gated step.

## Delivery Sequence

| Story | Scope | Decision |
| --- | --- | --- |
| **US-079** | Publish the current engine + Flutter + Jaspr `0.4.0-dev.1` line as coordinated stable `0.4.0` | No ADR (release execution under the existing multi-container and package-topology decisions) |

## Validation Ladder

- Workspace proof: `fvm dart pub get` plus `fvm dart run melos run validate` stay
  green through the shared family-release verifier.
- Package proof: `dart pub publish --dry-run` passes for the three packages in
  dependency order, tolerating only the expected dirty-git-tree warning before
  commit/publish.
- Release proof: the story packet records the `0.4.0` versions, the three
  package changelog scopes, and the final dependency-ordered publication that
  completed on 2026-06-24.
