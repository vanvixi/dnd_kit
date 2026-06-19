# Overview

## Current Behavior

The live package family is split across three published development baselines:

- `dnd_kit 0.3.0-dev.0` is the current published pure Dart engine release.
- `dnd_kit_flutter 0.3.0-dev.0` is the current published Flutter adapter
  release.
- `dnd_kit_jaspr 0.3.0-dev.1` is the current published Jaspr adapter release.

The workspace has unreleased package deltas after those versions:

- `dnd_kit` added the axis-aware shared auto-scroll contract (`DndScrollAxis`
  plus the `axis` parameter on `dndAutoScrollVelocity`).
- `dnd_kit_flutter` adopted the shared axis-aware contract for horizontal
  auto-scroll.
- `dnd_kit_jaspr` adopted horizontal auto-scroll and fixed drag-overlay
  controller rebinding after a controlled `DndScope` controller swap.

## Target Behavior

The family is promoted from the `0.3.0-dev` line to a coordinated stable
`0.3.0` release, prepared in publish order:

1. `dnd_kit 0.3.0`
2. `dnd_kit_flutter 0.3.0` depending on `dnd_kit: ^0.3.0`
3. `dnd_kit_jaspr 0.3.0` depending on `dnd_kit: ^0.3.0`

The promotion is justified because the axis-aware auto-scroll contract is now
adopted by both adapters and the API has soaked through the examples long enough
to close. As a `0.x` release this is not a `1.0` API freeze: any later breaking
change is still permitted via `0.4.0`.

Each package consolidates its `0.3.0-dev.*` changelog entries into a single
`0.3.0` section, the workspace validates cleanly, and publish dry-runs pass so
the final pub.dev publish can be executed by the maintainer without additional
repo edits.

## Affected Users

- Maintainer publishing the package family.
- Flutter applications depending on `dnd_kit_flutter`.
- Jaspr applications depending on `dnd_kit_jaspr`.
- Custom adapters or pure-Dart consumers depending on `dnd_kit`.

## Affected Product Docs

- `README.md`
- `docs/product/release-roadmap.md`
- `packages/dnd_kit/CHANGELOG.md`
- `packages/dnd_kit_flutter/CHANGELOG.md`
- `packages/dnd_kit_jaspr/CHANGELOG.md`

## Non-Goals

- Introducing a new package topology or another rename.
- Changing runtime behavior beyond the already-landed package deltas.
- Automating credentialed pub.dev publish inside the repository.
