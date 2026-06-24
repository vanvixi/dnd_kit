# Exec Plan

## Goal

Prepare and verify the coordinated stable `0.4.0` pub.dev release for
`dnd_kit`, `dnd_kit_flutter`, and `dnd_kit_jaspr`, then document the exact
publish order and the remaining human-gated irreversible publish step.

## Scope

In scope:

- Confirm the repository package metadata and changelogs are promoted from
  `0.4.0-dev.1` to `0.4.0`.
- Reuse the shared family verifier to prove workspace validation and package
  dry-runs.
- Record the publish order and final publish outcome in the story evidence.
- Keep the release packet connected to the stories that prepared this release
  line (`US-076`, `US-077`, and `US-078`).

Out of scope:

- New runtime features beyond the already-landed `0.4.0-dev.*` changes.
- Publishing any legacy umbrella/core topology or alternate package family.
- Running the irreversible credentialed pub.dev publish inside this setup task.

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
4. Release metadata alignment.
5. Verification.
6. Harness update.

## Stop Conditions

Pause for human confirmation if:

- Package version direction becomes ambiguous.
- Validation requirements need to be weakened.
- pub.dev account state or package ownership blocks publishing in a way local
  dry-runs cannot resolve.
- The irreversible final publish step is about to run.
