# Overview

## Current Behavior

The current coordinated stable family release packet stops at `US-073`, which
closed the `0.3.1` line. Since then, the repository has advanced and published
the next coordinated development line:

- `dnd_kit 0.4.0-dev.1` now carries the shared production-ready
  multi-container contract and default move policy.
- `dnd_kit_flutter 0.4.0-dev.1` depends on `dnd_kit: ^0.4.0-dev.1` and exposes
  the supported Flutter multi-container surface.
- `dnd_kit_jaspr 0.4.0-dev.1` depends on `dnd_kit: ^0.4.0-dev.1` and exposes
  the supported Jaspr/browser multi-container surface.

The hosted website has also adopted that supported Jaspr surface in Phase 30,
but no coordinated story packet yet captures the stable `0.4.0` family release
itself.

## Target Behavior

The package family is published as a coordinated stable release in dependency
order:

1. `dnd_kit 0.4.0`
2. `dnd_kit_flutter 0.4.0` depending on `dnd_kit: ^0.4.0`
3. `dnd_kit_jaspr 0.4.0` depending on `dnd_kit: ^0.4.0`

The release packet proves the prepared stable line with the shared family
verification command, keeps changelog truth aligned with the package versions,
and documents the remaining maintainer-run irreversible publish step without
introducing new runtime scope.

## Affected Users

- Maintainer publishing the package family to pub.dev.
- Pure-Dart consumers depending on `dnd_kit`.
- Flutter applications depending on `dnd_kit_flutter`.
- Jaspr applications depending on `dnd_kit_jaspr`.

## Affected Product Docs

- `docs/product/release-roadmap.md`
- `packages/dnd_kit/CHANGELOG.md`
- `packages/dnd_kit_flutter/CHANGELOG.md`
- `packages/dnd_kit_jaspr/CHANGELOG.md`
- `docs/stories/phase-28-cross-adapter-multi-container/README.md`
- `docs/stories/phase-29-production-ready-multi-container/README.md`
- `docs/stories/phase-30-website-multi-container-showcase/US-078-website-kanban-supported-multi-container.md`

## Non-Goals

- Adding new runtime behavior beyond the already-landed `0.4.0-dev.*` package
  deltas.
- Changing package topology, adapter boundaries, or multi-container semantics.
- Automating credentialed pub.dev publication inside the repository.
