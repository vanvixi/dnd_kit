# Validation

## Proof Strategy

Before the story is done, the workspace must resolve and validate against the
new package versions, and each package must pass `dart pub publish --dry-run`
in dependency order so the remaining irreversible publish act is purely a
maintainer confirmation step.

## Test Plan

| Layer | Cases |
| --- | --- |
| Unit | Existing engine, Flutter, and Jaspr package tests continue to pass under the full workspace validation lane. |
| Integration | Existing adapter/example suites continue to pass under `fvm dart run melos run validate`. |
| E2E | Not required beyond the existing browser/example proof already exercised by the validation lane. |
| Platform | `dart pub get`, `fvm dart run melos run validate`, and `fvm dart pub publish --dry-run` in `packages/dnd_kit`, `packages/dnd_kit_flutter`, and `packages/dnd_kit_jaspr` all pass. |
| Performance | Not required; no new runtime hot path beyond already-verified feature stories. |
| Logs/Audit | Harness intake/story/trace records capture versions, publish order, and any blocker. |

## Fixtures

- Current workspace with package-local changelogs and version metadata.
- Live pub.dev package metadata for `dnd_kit`, `dnd_kit_flutter`, and
  `dnd_kit_jaspr`.

## Commands

```text
dart pub get
fvm dart run melos run validate
cd packages/dnd_kit && fvm dart pub publish --dry-run
cd packages/dnd_kit_flutter && fvm dart pub publish --dry-run
cd packages/dnd_kit_jaspr && fvm dart pub publish --dry-run
```

## Acceptance Evidence

- Prepared versions:
  - `dnd_kit 0.3.0`
  - `dnd_kit_flutter 0.3.0` depending on `dnd_kit: ^0.3.0`
  - `dnd_kit_jaspr 0.3.0` depending on `dnd_kit: ^0.3.0`
- Each package's `0.3.0-dev.*` changelog entries are consolidated into a single
  `0.3.0` section.
- `fvm dart run tool/verify_family_release.dart` passed on 2026-06-19, running
  `dart pub get`, `fvm dart run melos run validate`, and
  `fvm dart pub publish --dry-run` for `packages/dnd_kit`,
  `packages/dnd_kit_flutter`, and `packages/dnd_kit_jaspr` in publish order.
- Each dry-run reported only the expected dirty-git-tree warning for modified
  checked-in `CHANGELOG.md`, `README.md`, and `pubspec.yaml` before the release
  prep is committed.
- Maintainer-run publish order remains:
  `dnd_kit -> dnd_kit_flutter -> dnd_kit_jaspr`.
