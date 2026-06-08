# US-002 Upgrade Melos Workspace Tooling To 7.8.1

## Status

implemented

## Lane

normal

## Product Contract

The workspace must use Melos `^7.8.1` for monorepo package bootstrap and
validation scripts. The Melos config should avoid removed configuration and
match current Melos workspace expectations.

## Relevant Product Docs

- `docs/product/package-architecture.md`
- `docs/product/release-roadmap.md`

## Acceptance Criteria

- Root `pubspec.yaml` depends on `melos: ^7.8.1`.
- Root dependency resolution succeeds.
- `melos.yaml` does not use removed `command.bootstrap.usePubspecOverrides`.
- Melos workspace configuration lives in the root `pubspec.yaml`.
- Package members use Dart workspace resolution.
- Intra-workspace package dependencies use version constraints instead of
  `path:` overrides.
- Root `pubspec.lock` is committed for workspace tool reproducibility.
- Generated per-package `pubspec_overrides.yaml`, package lockfiles, `.dart_tool`,
  and IDE files remain ignored.
- `melos bootstrap` succeeds.
- `melos run analyze` succeeds.
- Harness story verification confirms the resolved Melos binary is available.

## Design Notes

- Commands: `fvm flutter pub get`, `fvm flutter pub run melos bootstrap`,
  `fvm flutter pub run melos run analyze`.
- Queries: none.
- API: no public Dart API changes.
- Tables: none.
- Domain rules: package boundaries remain unchanged.
- UI surfaces: none.

## Validation

When updating durable proof status, use numeric booleans:
`scripts/bin/harness-cli story update --id US-002 --unit 1 --integration 1 --e2e 0 --platform 0`.

| Layer | Expected proof |
| --- | --- |
| Unit | `fvm flutter pub run melos --version` reports `7.8.1`; `fvm dart analyze` passes. |
| Integration | `fvm flutter pub run melos bootstrap` and `fvm flutter pub run melos run analyze` pass across packages. |
| E2E | Not required; no user-facing app flow changes. |
| Platform | Not required; no platform build behavior changes. |
| Release | Root `pubspec.lock` captures the resolved Melos toolchain. |

## Harness Delta

- Adds a dedicated story for monorepo tooling upgrade evidence.

## Evidence

- `fvm flutter pub get` passed and resolved `melos 7.8.1`.
- `fvm dart run melos --version` returned `7.8.1`.
- `fvm dart pub deps --style=compact` showed `melos 7.8.1`.
- `fvm dart run melos bootstrap` passed and bootstrapped 4 packages.
- `fvm dart format .` completed with no changes needed.
- `fvm dart analyze` passed with no issues.
- `fvm dart run melos run analyze` passed for all 4 packages.
- `fvm dart run melos run test` passed with 0 test packages.
- `scripts/bin/harness-cli story verify US-002` passed.
