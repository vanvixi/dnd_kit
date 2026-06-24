# Overview

## Current Behavior

Multi-container is currently usable but not production-ready as a library
feature:

- `dnd_kit` owns the experimental helper contract
  (`SortableContainer`, `SortableMultiContainer`) after Phase 28.
- Applications still own the default interaction semantics for target
  resolution and insertion behavior, typically by combining raw
  `DndDroppable`, a custom collision detector, and app-side `onDragEnd`
  handling.
- The Flutter example still uses a two-phase cross-container update to avoid
  duplicate registration churn during a move.
- Jaspr has helper parity and a focused browser proof, but not a supported
  adapter-level multi-container surface or gallery-grade production example.

The library therefore exposes building blocks, not a complete product-grade
feature contract.

## Target Behavior

Multi-container becomes a supported production-ready capability across the
package family:

- the library owns default interaction semantics for the common board/list
  case, including target resolution and insertion rules;
- Flutter and Jaspr expose adapter-level multi-container APIs instead of
  requiring every app to wire the low-level pieces itself;
- applications keep ownership of rendering, theming, animation, and state
  mutation;
- applications can override the default interaction policy when their product
  rules differ;
- the feature is documented and validated as production-ready rather than only
  experimental.

This preserves app UX freedom in presentation while making drag/drop meaning a
library-owned contract.

## Affected Users

- Flutter application developers building production board, workflow, or
  dashboard UIs.
- Jaspr application developers who need the same production behavior semantics
  in the browser.
- Maintainers who need one documented, testable multi-container contract
  instead of example-owned behavior.

## Affected Product Docs

- `docs/product/api-principles.md`
- `docs/product/package-architecture.md`
- `docs/product/release-roadmap.md`
- `docs/ARCHITECTURE.md`

## Non-Goals

- Owning visual styling, theme tokens, motion systems, or app-specific layout.
- Preventing advanced adopters from supplying custom interaction policy.
- Taking over application state mutation or persistence.
- Solving every advanced drag domain such as nested virtualized canvases in the
  first production-ready slice.
