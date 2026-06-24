# Validation

## Proof Strategy

Before this story is done, the workspace must resolve and validate against the
prepared `0.4.0` package line, and each package must pass
`dart pub publish --dry-run` in dependency order before the actual pub.dev
publication is attempted.

## Test Plan

| Layer | Cases |
| --- | --- |
| Unit | Existing package unit coverage continues to pass through the shared family validation lane. |
| Integration | Existing adapter/example suites continue to pass under `fvm dart run melos run validate`, as exercised by the shared family verifier. |
| E2E | Not required beyond the existing browser/example proof already exercised by the validation lane. |
| Platform | `fvm dart pub get` and `fvm dart run tool/verify_family_release.dart` pass, and the verifier completes publish dry-runs for `packages/dnd_kit`, `packages/dnd_kit_flutter`, and `packages/dnd_kit_jaspr` in dependency order. |
| Performance | Not required; no new runtime hot path is introduced by the release packet itself. |
| Logs/Audit | Harness intake/story/trace records capture the prepared versions, dry-run proof, final publish order, and any blocker. |

## Fixtures

- Current workspace with package versions promoted to `0.4.0`.
- Package-local changelogs for `dnd_kit`, `dnd_kit_flutter`, and
  `dnd_kit_jaspr`.
- `tool/verify_family_release.dart`.

## Commands

```text
fvm dart pub get
fvm dart run tool/verify_family_release.dart
```

## Acceptance Evidence

- Prepared versions remain:
  - `dnd_kit 0.4.0`
  - `dnd_kit_flutter 0.4.0` depending on `dnd_kit: ^0.4.0`
  - `dnd_kit_jaspr 0.4.0` depending on `dnd_kit: ^0.4.0`
- Changelog scope matches the landed `0.4.0` work:
  - `dnd_kit`: shared helper parity plus production-ready multi-container
    policy.
  - `dnd_kit_flutter`: supported multi-container adapter surface plus example
    adoption.
  - `dnd_kit_jaspr`: supported multi-container adapter surface plus browser
    proof over the shared production contract.
- Final publish order remains:
  `dnd_kit -> dnd_kit_flutter -> dnd_kit_jaspr`.
- Verified 2026-06-24:
  - `fvm dart run tool/verify_family_release.dart` -> pass.
  - The verifier completed workspace dependency resolution, full
    `fvm dart run melos run validate`, and dependency-ordered
    `fvm dart pub publish --dry-run` for `packages/dnd_kit`,
    `packages/dnd_kit_flutter`, and `packages/dnd_kit_jaspr`.
  - All three package dry-runs reported only the expected dirty-git-tree
    warning for modified `CHANGELOG.md` and `pubspec.yaml` files.
- Published 2026-06-24:
  - `dnd_kit 0.4.0`
  - `dnd_kit_flutter 0.4.0`
  - `dnd_kit_jaspr 0.4.0`
- Final publish order was:
  `dnd_kit -> dnd_kit_flutter -> dnd_kit_jaspr`.
