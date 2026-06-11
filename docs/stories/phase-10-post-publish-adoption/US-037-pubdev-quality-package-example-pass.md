# US-037 Pub.dev Quality And Package Example Pass

## Status

implemented

## Lane

normal

## Product Contract

The published `dnd_kit` and `dnd_kit_core` packages must include package-local
example surfaces that pub.dev can render while keeping the full runnable
showcase apps in the repository-level `examples/` directory.

## Relevant Product Docs

- `docs/product/release-roadmap.md`
- `docs/product/package-architecture.md`
- `packages/dnd_kit/README.md`

## Acceptance Criteria

- `packages/dnd_kit/example/example.md` exists and contains an illustrative
  code sample using `DndScope`, `DndDroppable`, `DndDraggable`, and
  `DndDragOverlay`.
- `packages/dnd_kit_core/example/example.md` exists and contains an
  illustrative pure Dart sample using core geometry and collision detectors.
- Package READMEs avoid duplicate example sections because pub.dev renders the
  package-local example files in the Example tab.
- The workspace root pubspec must not define `publish_to`, so pub.dev
  repository verification can inspect package pubspecs in the cloned monorepo
  without being blocked by root workspace metadata.
- `dnd_kit` and `dnd_kit_core` have new publishable development versions so
  the package archives can include the example fixes.
- Public API shape remains unchanged.

## Design Notes

- Commands:
  - `git diff --check`
  - `fvm dart analyze packages/dnd_kit_core`
  - `fvm dart test packages/dnd_kit_core`
  - `fvm flutter analyze packages/dnd_kit`
  - `fvm flutter test packages/dnd_kit`
  - `cd packages/dnd_kit_core && fvm dart pub publish --dry-run`
  - `cd packages/dnd_kit && fvm flutter pub publish --dry-run`
- Queries:
  - `scripts/bin/harness-cli query matrix`
- API:
  - No public API changes.
- Tables:
  - No schema changes.
- Domain rules:
  - Applications still own their data; examples only report drag/drop intent.
- Repository verification:
  - Package pubspecs do not define `publish_to`.
  - The workspace root pubspec also avoids `publish_to` because pub.dev
    repository verification traverses the cloned monorepo.
- UI surfaces:
  - Pub.dev Example tab.

## Validation

When updating durable proof status, use numeric booleans:
`scripts/bin/harness-cli story update --id <id> --unit 1 --integration 1 --e2e 0 --platform 0`.

| Layer | Expected proof |
| --- | --- |
| Unit | `fvm dart test packages/dnd_kit_core` and `fvm flutter test packages/dnd_kit` |
| Integration | `cd packages/dnd_kit_core && fvm dart pub publish --dry-run`; `cd packages/dnd_kit && fvm flutter pub publish --dry-run` |
| E2E | Not required |
| Platform | Not required |
| Release | `git diff --check`, `fvm dart analyze packages/dnd_kit_core`, and `fvm flutter analyze packages/dnd_kit` |

## Harness Delta

Phase 10 is introduced as the post-publish adoption and pub.dev quality loop.

## Evidence

- `git diff --check` passed.
- `fvm dart analyze packages/dnd_kit_core` passed.
- `fvm dart test packages/dnd_kit_core` passed.
- `fvm flutter analyze packages/dnd_kit` passed.
- `fvm flutter test packages/dnd_kit` passed.
- `cd packages/dnd_kit_core && fvm dart pub publish --dry-run` produced the
  expected package archive including `example/example.md`; it reported the
  expected dirty git warning for changed package files before commit.
- `cd packages/dnd_kit && fvm flutter pub publish --dry-run` produced the
  expected package archive including `example/example.md`; it reported the
  expected dirty git warning for changed package files before commit.
- Root workspace `pubspec.yaml` no longer defines `publish_to`, preventing
  pub.dev repository verification from mistaking workspace metadata for a
  package-level publish target.
