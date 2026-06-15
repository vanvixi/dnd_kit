# US-046 Publish dnd_kit_core, dnd_kit_flutter, And dnd_kit 0.1.0

## Status

implemented

## Lane

normal

## Product Contract

Cut the first public release of the engine, the Flutter adapter, and the
umbrella: `dnd_kit_core 0.1.0`, `dnd_kit_flutter 0.1.0`, and `dnd_kit 0.1.0`.
Per ADR 0014, stability solidifies bottom-up and a release must not depend on a
pre-release constraint, so packages publish in dependency order:

- `dnd_kit_core` is published first at `0.1.0`.
- `dnd_kit_flutter` is published second at `0.1.0`, depending on
  `dnd_kit_core: ^0.1.0` (not `^0.1.0-dev.2`).
- `dnd_kit` umbrella is published third at `0.1.0`, depending on
  `dnd_kit_flutter: ^0.1.0`. This supersedes the pre-rename `dnd_kit` monolith
  currently on pub.dev at `0.1.0-dev.1`, replacing it with the thin umbrella
  that re-exports `dnd_kit_flutter` (the public API is unchanged).

`0.1.0` is a first public release in the `0.x` line, not a 1.0 API-freeze;
breaking changes remain allowed on minor bumps until 1.0.

This story does not change runtime behavior; the `0.1.0` code is the
`0.1.0-dev.2` code with release metadata.

## Relevant Product Docs

- `packages/dnd_kit_core/pubspec.yaml`
- `packages/dnd_kit_core/CHANGELOG.md`
- `packages/dnd_kit_flutter/pubspec.yaml`
- `packages/dnd_kit_flutter/CHANGELOG.md`
- `packages/dnd_kit/pubspec.yaml`
- `docs/decisions/0014-release-versioning-brand-home-strategy.md`

## Acceptance Criteria

- `dnd_kit_core` `version` is `0.1.0` with a `## 0.1.0` CHANGELOG entry.
- `dnd_kit_flutter` `version` is `0.1.0`, depends on `dnd_kit_core: ^0.1.0`, and
  has a `## 0.1.0` CHANGELOG entry.
- `dnd_kit` umbrella `version` is `0.1.0`, depends on `dnd_kit_flutter: ^0.1.0`,
  and has a `## 0.1.0` CHANGELOG entry. Publishing it supersedes the stale
  pre-rename `dnd_kit` monolith currently on pub.dev at `0.1.0-dev.1`.
- No published `0.1.0` package depends on a `-dev` pre-release constraint.
- `fvm dart pub publish --dry-run` passes for `dnd_kit_core`, `dnd_kit_flutter`,
  and `dnd_kit` with only the expected dirty-git-tree warning before commit.
- `fvm dart run melos run validate` passes after the version/dependency updates.
- Publish order is documented and followed: `dnd_kit_core`, then
  `dnd_kit_flutter`, then `dnd_kit`.

## Design Notes

- Commands (run by the maintainer with pub.dev credentials, after the version
  bump is committed):
  - `fvm dart pub publish -C packages/dnd_kit_core`
  - then `fvm dart pub publish -C packages/dnd_kit_flutter`
  - then `fvm dart pub publish -C packages/dnd_kit`
- Publishing is irreversible: a published version cannot be deleted (only
  retracted within 7 days or discontinued). Confirm metadata before publishing.
- Queries: `scripts/bin/harness-cli query matrix`.
- API: no code changes.
- Tables: story row `US-046`.
- Domain rules: external provider (pub.dev) release; bottom-up order is
  mandatory because `dnd_kit_flutter` depends on `dnd_kit_core`.
- UI surfaces: none.

## Validation

When updating durable proof status, use numeric booleans:
`scripts/bin/harness-cli story update --id US-046 --unit 1 --integration 1 --e2e 0 --platform 0`.

| Layer | Expected proof |
| --- | --- |
| Unit | `dnd_kit_core` tests pass at `0.1.0`. |
| Integration | `dnd_kit_flutter` adapter and example suites pass against `dnd_kit_core: ^0.1.0`. |
| E2E | Not required. |
| Platform | Not required. |
| Release | `fvm dart run melos run validate` passes; `fvm dart pub publish --dry-run` is clean for both packages; after publish, both `0.1.0` versions resolve from pub.dev in dependency order. |

## Harness Delta

No Harness tool changes expected. Implements the bottom-up release order from
ADR 0014.

## Evidence

- `packages/dnd_kit_core/pubspec.yaml`, `packages/dnd_kit_flutter/pubspec.yaml`,
  and `packages/dnd_kit/pubspec.yaml` all publish `version: 0.1.0`.
- Dependency constraints are now stable-only end to end:
  `dnd_kit_flutter` depends on `dnd_kit_core: ^0.1.0`, and the `dnd_kit`
  umbrella depends on `dnd_kit_flutter: ^0.1.0`.
- `scripts/bin/harness-cli story verify US-046` passed on June 15, 2026. The
  verify command ran `fvm dart run melos run validate`, which completed with
  format clean, analyzer success across all workspace packages, and passing
  test suites for `dnd_kit_core`, `dnd_kit_flutter`, `kanban_board`,
  `multi_container_sortable`, and `example_gallery`.
- Pub.dev now shows the published stable versions:
  - `https://pub.dev/packages/dnd_kit_core` -> `0.1.0`
  - `https://pub.dev/packages/dnd_kit_flutter` -> `0.1.0`
  - `https://pub.dev/packages/dnd_kit` -> `0.1.0`
- As checked on June 15, 2026, the live pub.dev pages for all three packages
  show the `0.1.0` release as published "in the last hour", confirming the
  release sequence completed after the version-prep work.
- The published `dnd_kit` page now presents the thin umbrella description and
  links to `dnd_kit_flutter`; the published `dnd_kit_flutter` and
  `dnd_kit_core` pages also expose the expected family cross-links and API
  reference links.
