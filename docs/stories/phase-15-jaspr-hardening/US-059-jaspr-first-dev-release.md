# US-059 Jaspr First Development Release Standardization

## Status

planned

## Lane

normal

## Product Contract

`dnd_kit_jaspr` has not published a public package release yet. After Phase C
hardening closes with US-058, the repository must standardize the package's
release metadata, changelog presentation, and publish proof so the first public
Jaspr adapter release ships intentionally as `0.1.0-dev.1` rather than treating
the existing local `0.1.0-dev.0` state as if it had already been published.

## Relevant Product Docs

- `docs/product/package-architecture.md`
- `docs/decisions/0014-release-versioning-brand-home-strategy.md`
- `docs/stories/phase-15-jaspr-hardening/README.md`
- `docs/stories/phase-15-jaspr-hardening/US-058-jaspr-diagnostics-alignment.md`
- `packages/dnd_kit_jaspr/pubspec.yaml`
- `packages/dnd_kit_jaspr/CHANGELOG.md`

## Acceptance Criteria

- `dnd_kit_jaspr` publishes its first public package release as
  `0.1.0-dev.1`, with package metadata and dependency constraints reflecting the
  actual shipped surface.
- The package changelog clearly presents the first published Jaspr release
  without implying that an unpublished version was already available on pub.dev.
- `dart pub publish --dry-run` succeeds for `packages/dnd_kit_jaspr`, and the
  story records the exact publish command/order and any follow-up release notes.
- Package-facing docs (`README.md`, changelog, family cross-links if touched)
  stay aligned with ADR 0014: adapters may ship dev releases directly while the
  `dnd_kit` umbrella remains stable-only.

## Design Notes

- Commands:
  `fvm dart run melos run validate`
  `cd packages/dnd_kit_jaspr && fvm dart pub publish --dry-run`
  `scripts/bin/harness-cli query matrix`
- Queries:
  `rg -n "0\\.1\\.0-dev|Unreleased|publish" packages/dnd_kit_jaspr docs`
- API:
  Package versioning and release metadata only; no new runtime API expected.
- Domain rules:
  This is a release-standardization story, not a feature story. It should ship
  only after the Phase C hardening surface is complete and validated.
- UI surfaces:
  pub.dev/package-facing metadata and documentation for `dnd_kit_jaspr`.

## Validation

When updating durable proof status, use numeric booleans:
`scripts/bin/harness-cli story update --id US-059 --unit 0 --integration 0 --e2e 0 --platform 1`.

| Layer | Expected proof |
| --- | --- |
| Unit | Not required unless release prep reveals package-local logic changes. |
| Integration | Not required unless docs or examples need executable proof beyond release validation. |
| E2E | Not required for the release act itself. |
| Platform | `fvm dart run melos run validate` and `cd packages/dnd_kit_jaspr && fvm dart pub publish --dry-run` pass with the finalized version/changelog metadata. |
| Release | Story records the first public `dnd_kit_jaspr 0.1.0-dev.1` publish outcome, or the exact blocker if publishing is deferred. |

## Harness Delta

No Harness process change expected. This story exists to keep the first Jaspr
package release explicit and auditable after the adapter hardening stories.

## Evidence

- Created 2026-06-16 after confirming that `dnd_kit_jaspr` is still unpublished
  while its local changelog already contains `0.1.0-dev.0` plus `Unreleased`.
- Sequenced after US-058 by user direction so diagnostics parity lands before
  the first public Jaspr dev release.
