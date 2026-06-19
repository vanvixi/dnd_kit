# Exec Plan

## Goal

Prepare and verify the coordinated stable `0.3.0` pub.dev release for
`dnd_kit`, `dnd_kit_flutter`, and `dnd_kit_jaspr` (promoting the `0.3.0-dev`
line), then document the exact publish order and the remaining human-gated
irreversible publish step.

## Scope

In scope:

- Confirm the current published versions on pub.dev and the unpublished local
  deltas in the three package changelogs.
- Bump package versions to stable `0.3.0` and repoint adapter dependency
  constraints to `dnd_kit: ^0.3.0`.
- Update release-facing docs/story records so the next publish act is explicit
  and auditable.
- Run workspace validation plus `dart pub publish --dry-run` for the three
  packages in publish order.
- Record the commands and exact version/order for the eventual maintainer-run
  publish.

Out of scope:

- New runtime features beyond the already-implemented story deltas.
- Stable `1.0` release planning.
- Publishing any superseded historical package such as `dnd_kit_core`.

## Risk Classification

Risk flags:

- External systems.
- Public contracts.
- Existing behavior.

Hard gates:

- External provider behavior (`pub.dev` publish).

## Work Phases

1. Discovery.
2. Design.
3. Validation planning.
4. Implementation.
5. Verification.
6. Harness update.

## Stop Conditions

Pause for human confirmation if:

- Package version direction becomes ambiguous.
- Validation requirements need to be weakened.
- pub.dev metadata or account state blocks publishing in a way local dry-runs
  cannot resolve.
- The irreversible final publish step is about to run.
