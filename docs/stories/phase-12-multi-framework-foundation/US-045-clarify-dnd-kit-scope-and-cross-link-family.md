# US-045 Clarify dnd_kit Flutter Scope And Cross-Link The Package Family

## Status

implemented

## Lane

normal

## Product Contract

Per ADR 0014, the bare `dnd_kit` package is the Flutter entry point (a
stable-only umbrella over `dnd_kit_flutter`), not a framework-neutral package.
Because the name looks neutral but pulls the Flutter SDK, the package metadata
and docs must state this plainly and route Jaspr users to `dnd_kit_jaspr`.

Every published package must cross-link the rest of the family and the project
home so a reader landing on any one package can find the right entry point. The
neutral project home is the GitHub repository README plus the GitHub Pages site
at `https://vanvixi.github.io/dnd_kit/`; no code-less landing package is
published.

This is a documentation and metadata story. No library exports, public API, or
runtime behavior change.

## Relevant Product Docs

- `README.md`
- `packages/dnd_kit/pubspec.yaml`
- `packages/dnd_kit/README.md`
- `packages/dnd_kit_flutter/README.md`
- `packages/dnd_kit_core/README.md`
- `docs/product/package-architecture.md`
- `docs/decisions/0014-release-versioning-brand-home-strategy.md`

## Acceptance Criteria

- `packages/dnd_kit/pubspec.yaml` `description` states that `dnd_kit` is the
  Flutter entry point (umbrella re-exporting `dnd_kit_flutter`) and that it
  publishes stable releases only.
- `packages/dnd_kit/README.md` opens by stating it is the Flutter entry point,
  notes it is stable-only, and directs Jaspr users to `dnd_kit_jaspr` (described
  as planned until that package exists).
- Each package README (`dnd_kit_core`, `dnd_kit_flutter`, `dnd_kit`) contains a
  "dnd_kit family" section that cross-links the other family packages and the
  home site `https://vanvixi.github.io/dnd_kit/`.
- The root `README.md` states which package to use per framework: `dnd_kit` or
  `dnd_kit_flutter` for Flutter, `dnd_kit_jaspr` (planned) for Jaspr, and
  `dnd_kit_core` for the shared engine.
- No `lib/` exports, pubspec dependencies, or versions change; this is copy and
  metadata only.
- Jaspr references are phrased as planned/coming until `dnd_kit_jaspr` is
  actually published.

## Design Notes

- Commands: edit READMEs and the `dnd_kit` pubspec `description`; run
  `fvm dart run melos run validate` to confirm nothing breaks.
- Queries: `scripts/bin/harness-cli query matrix`.
- API: no code or export changes.
- Tables: story row `US-045`.
- Domain rules: docs/metadata only; do not touch `lib/` or dependency lists.
- UI surfaces: none.
- Decision: implements ADR 0014; the "dnd_kit family" marker phrase is the
  mechanical hook for the verify command.

## Validation

When updating durable proof status, use numeric booleans:
`scripts/bin/harness-cli story update --id US-045 --unit 0 --integration 0 --e2e 0 --platform 0`.

Mechanical verify command (passes only when all three package READMEs carry the
family cross-link marker):

```bash
bash -c 'for f in packages/dnd_kit_core/README.md packages/dnd_kit_flutter/README.md packages/dnd_kit/README.md; do grep -q "dnd_kit family" "$f" || exit 1; done'
```

| Layer | Expected proof |
| --- | --- |
| Unit | Not applicable; no code behavior changes. |
| Integration | Not applicable; no code behavior changes. |
| E2E | Not required. |
| Platform | Not required. |
| Release | `fvm dart run melos run validate` still passes; `fvm dart pub publish --dry-run` for `dnd_kit` shows the updated description; the mechanical verify command above exits 0. |

## Harness Delta

No Harness tool changes expected. Implements durable decision ADR 0014.

## Evidence

- `packages/dnd_kit/pubspec.yaml` description now reads: "Stable Flutter entry
  point for the dnd_kit drag-and-drop toolkit; re-exports dnd_kit_flutter. For
  Jaspr, use dnd_kit_jaspr."
- `packages/dnd_kit/README.md` opens by stating it is the stable Flutter entry
  point and routes Jaspr users to `dnd_kit_jaspr` (planned), noting `dnd_kit`
  needs the Flutter SDK.
- A `## dnd_kit family` cross-link section (with the home site
  `https://vanvixi.github.io/dnd_kit/`) was added to the `dnd_kit_core`,
  `dnd_kit_flutter`, and `dnd_kit` READMEs.
- Root `README.md` gained a "Which package should I use?" section mapping
  framework -> package and stating the stable-only/dev cadence.
- `scripts/bin/harness-cli story verify US-045` passed: the family marker is
  present in all three package READMEs.
- `fvm dart run melos run validate` passed: format clean, analyze SUCCESS for all
  packages, all test suites passed.
- `fvm dart pub publish --dry-run` for `dnd_kit` reports only the expected
  dirty-git-tree warning; the new description is in the published metadata.
