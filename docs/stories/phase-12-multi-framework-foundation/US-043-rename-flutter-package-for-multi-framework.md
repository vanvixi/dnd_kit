# US-043 Rename Flutter Package And Add Umbrella For Multi-Framework

## Status

implemented

## Lane

normal

## Product Contract

The Flutter adapter package is renamed from `dnd_kit` to `dnd_kit_flutter` so the
package family becomes symmetric and ready for a second framework adapter
(`dnd_kit_jaspr`). After this story the layout is:

```text
dnd_kit_core     pure Dart engine, shared by every adapter
dnd_kit_flutter  Flutter adapter (the package previously named dnd_kit)
dnd_kit          thin umbrella that re-exports dnd_kit_flutter
```

The brand name `dnd_kit` is kept as a thin umbrella package that re-exports the
Flutter adapter. This preserves the short pub.dev name and keeps the existing
public import `package:dnd_kit/dnd_kit.dart` working, so the rename is not a
breaking change for current Flutter users.

Drag-and-drop runtime semantics do not change. This is a packaging, naming, and
layering change only.

### Git History Is A First-Class Requirement

Preserving Git history through this rename is a primary, non-negotiable goal of
this story, not a nice-to-have. Every moved source file, test file, and package
directory must keep its history so that `git log --follow` and `git blame`
continue to trace each file back through the rename. The rename must be done with
rename-aware operations (`git mv` or equivalent). Deleting `packages/dnd_kit` and
recreating an unrelated `packages/dnd_kit_flutter` is explicitly disallowed,
because it would destroy the authorship and change history of the entire adapter.

This mirrors the same constraint already honored in US-035 (the inverse rename).

## Relevant Product Docs

- `README.md`
- `docs/ARCHITECTURE.md`
- `docs/product/package-architecture.md`
- `docs/product/release-roadmap.md`
- `docs/decisions/0007-dnd-kit-package-architecture.md`
- `docs/decisions/0008-main-dnd-kit-package.md`

## Acceptance Criteria

- `packages/dnd_kit` is renamed to `packages/dnd_kit_flutter` using `git mv` (or
  an equivalent rename-preserving operation), and `git log --follow` on at least
  one moved source file and one moved test file shows continuous history across
  the rename.
- The renamed package `pubspec.yaml` uses `name: dnd_kit_flutter`, and its
  `repository`/`homepage` paths point at the new package directory.
- The library barrel `lib/dnd_kit.dart` is renamed to `lib/dnd_kit_flutter.dart`
  via `git mv`, and the canonical adapter import becomes
  `package:dnd_kit_flutter/dnd_kit_flutter.dart`.
- All internal imports and the renamed package's own tests reference
  `package:dnd_kit_flutter/dnd_kit_flutter.dart` instead of
  `package:dnd_kit/dnd_kit.dart`.
- A new thin umbrella package `packages/dnd_kit` exists with
  `name: dnd_kit`, depends only on `dnd_kit_flutter`, and its
  `lib/dnd_kit.dart` re-exports the Flutter adapter so that
  `package:dnd_kit/dnd_kit.dart` keeps resolving the full public API.
- Examples and public-facing docs continue to import
  `package:dnd_kit/dnd_kit.dart` (served by the umbrella), so the umbrella
  re-export path stays continuously tested by the example suite.
- The workspace `pubspec.yaml` lists both `packages/dnd_kit_flutter` and
  `packages/dnd_kit`, and Melos validate scripts reference the renamed package.
- The layering rule still holds: `dnd_kit_core` stays pure Dart,
  `dnd_kit_flutter` depends on `dnd_kit_core`, and the `dnd_kit` umbrella depends
  only on `dnd_kit_flutter` (no inner package depends on the umbrella).
- A durable decision record is added or refreshed (amending/superseding
  ADR 0008) to document that the Flutter adapter is `dnd_kit_flutter` and
  `dnd_kit` is a re-export umbrella in a multi-framework family.

## Design Notes

- Commands: use `git mv` for the package directory and the `lib/dnd_kit.dart`
  barrel move; verify with `git log --follow <moved-file>` before committing.
  Avoid any delete-then-add sequence on moved files.
- Queries: `scripts/bin/harness-cli query matrix`.
- API: canonical adapter import becomes
  `package:dnd_kit_flutter/dnd_kit_flutter.dart`; the brand import
  `package:dnd_kit/dnd_kit.dart` keeps working through the umbrella.
- Tables: story row `US-043`.
- Domain rules: packaging/layering only; drag/drop runtime behavior unchanged.
  This is the first story of the multi-framework initiative that later adds a
  `dnd_kit_jaspr` adapter against the shared `dnd_kit_core` engine.
- UI surfaces: no user-facing example UI behavior changes are expected.
- Decision: this reverses the naming half of ADR 0008; record the new
  multi-framework naming/layering rationale as a fresh `docs/decisions/NNNN-*.md`
  plus `scripts/bin/harness-cli decision add`.

## Validation

When updating durable proof status, use numeric booleans:
`scripts/bin/harness-cli story update --id US-043 --unit 1 --integration 1 --e2e 0 --platform 0`.

| Layer | Expected proof |
| --- | --- |
| Unit | `dnd_kit_core` tests still pass; renamed `dnd_kit_flutter` unit tests pass through new imports. |
| Integration | Flutter adapter and example widget tests pass through both the `dnd_kit_flutter` direct import and the `dnd_kit` umbrella re-export. |
| E2E | Not required; no browser or app-level journey changes. |
| Platform | Not required; no native shell behavior changes. |
| Release | `fvm dart run melos run validate` passes; `fvm dart pub publish --dry-run` succeeds for `dnd_kit_flutter` and the `dnd_kit` umbrella; `git log --follow` confirms preserved history on moved files. |

## Harness Delta

No Harness tool changes required. Durable decision ADR 0013 was added amending
the naming half of ADR 0008.

## Evidence

- `git mv` moved the package directory and library barrel; `git diff --cached
  -M50% --summary` recorded all 15 `lib/src` files and 14 test files as renames
  at 97-100% similarity, so `git log --follow` traces them through the rename
  (including the earlier `dnd_kit_flutter` era).
- Because the `dnd_kit` umbrella reuses the original `packages/dnd_kit/` path,
  the 6 metadata files (barrel, pubspec, README, CHANGELOG, LICENSE, example.md)
  are recorded as new files under `dnd_kit_flutter` while the `dnd_kit`-named
  lineage continues on the umbrella path. No history is destroyed.
- New umbrella `packages/dnd_kit` re-exports `dnd_kit_flutter`; all three example
  suites import `package:dnd_kit/dnd_kit.dart` and pass, proving the re-export.
- `scripts/bin/harness-cli story verify US-043` passed, running
  `fvm dart run melos run validate`: format, workspace analyze, core tests,
  `dnd_kit_flutter` adapter tests, and the kanban/multi-container/example_gallery
  suites all passed.
- `fvm dart pub publish --dry-run` for both `dnd_kit_flutter` and the `dnd_kit`
  umbrella produced clean archives with only the expected dirty-git-tree warning.
- ADR 0013 (`docs/decisions/0013-multi-framework-package-naming.md`) recorded;
  ADR 0008 status annotated as amended.
- Committed as `Rename dnd_kit Flutter package to dnd_kit_flutter and add
  re-export umbrella`.
