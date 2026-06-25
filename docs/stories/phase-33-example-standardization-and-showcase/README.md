# Phase 33 - Example Standardization And Showcase Page

The documentation section (Phase 32) gave the website a concept taxonomy, but
the example apps did not match it: the Flutter and Jaspr galleries shared almost
no demos and used different structures. Before the website can host a showcase
page presenting Flutter and Jaspr side by side, the examples must converge on
one catalog.

This phase standardizes the examples, then builds the showcase page on top.

## Principle

- The canonical demo catalog mirrors the docs concept taxonomy, so examples,
  docs, and the showcase share one vocabulary.
- `examples/` holds exactly two gallery projects (`flutter_example_gallery`,
  `jaspr_example_gallery`); every demo lives under `lib/demos/` as a file or a
  subfolder. The standalone Flutter packages fold into the Flutter gallery.
- A spec lands before demo code, so the parity target is agreed first.

## Delivery Sequence

| Story | Scope | Decision |
| --- | --- | --- |
| **US-083** | Define the examples standard: canonical demo catalog, naming/structure conventions, and the Flutter/Jaspr parity matrix (no demo code) | No ADR (product contract doc under the existing examples decisions) |
| **US-084** | Consolidate `examples/` into two galleries: rename `example_gallery` → `flutter_example_gallery`, fold the standalone packages into `lib/demos/` (`basic`, `multi-container`), remove the legacy `kanban_board` app | No ADR (structure under the examples standard) |
| **US-085** | Parity for `collision` + `sensors`: add both demos to both galleries | No ADR (demo content under the examples standard) |
| **US-086** | Bring the Flutter gallery to the full catalog: add `modifiers`, `auto-scroll`, `sortable`, `accessibility` | No ADR (demo content under the examples standard) |
| **US-087** | Add the `multi-container` demo to the Jaspr gallery — completing Flutter/Jaspr catalog parity | No ADR (demo content under the examples standard) |
| US-088+ | Add the website showcase page presenting Flutter and Jaspr demos | TBD (Flutter-on-web delivery decided in that story) |

Catalog parity is complete (US-083–US-087). The showcase story is the remaining
placeholder.

## Validation Ladder

- US-083 is a documentation-only story: `docs/product/examples-standard.md`
  defines the catalog and parity matrix, and `examples/README.md` points to it.
- US-084 is verified by `dart analyze`, `dart format`, the
  `flutter_example_gallery` widget tests, and `melos run validate:affected`
  staying green after the restructure.
