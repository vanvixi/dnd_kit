# Exec Plan

## Goal

Prepare a high-risk implementation packet that moves the experimental
multi-container sortable helpers into `dnd_kit` and lets both
`dnd_kit_flutter` and `dnd_kit_jaspr` expose the same shared contract without
changing stable sortable behavior.

## Scope

In scope:

- hoist `SortableContainer` and `SortableMultiContainer` from
  `dnd_kit_flutter` into the pure Dart engine;
- preserve existing Flutter import paths by turning the adapter-local source
  into a compatibility re-export;
- expose the same experimental helper contract from `dnd_kit_jaspr`;
- add focused proof in the engine plus both adapters for shared cross-container
  move intent;
- update roadmap, backlog, and package-facing docs so the parity work is
  explicitly tracked.

Out of scope:

- stabilizing the multi-container API for `1.0`;
- introducing a new adapter-owned multi-container widget or component family;
- nested sortable layouts, virtualization, or simultaneous two-axis drag
  policies;
- release publication or version-finalization work beyond story-level planning.

## Risk Classification

Risk flags:

- Public contracts.
- Cross-platform.
- Existing behavior.
- Weak proof.
- Multi-domain.

Hard gates:

- None from the intake hard-gate list; this story is high-risk because it
  changes shared package boundaries and public experimental imports across the
  engine plus both adapters.

## Work Phases

1. Discovery.
2. Design.
3. Validation planning.
4. Implementation.
5. Verification.
6. Harness update.

## Stop Conditions

Pause for human confirmation if:

- hoisting the helpers requires a different public API shape than the existing
  Flutter contract;
- adapter parity would require a second move-intent algorithm instead of shared
  engine logic;
- validation requirements need to be weakened because browser or example proof
  is unavailable;
- the change needs a new ADR instead of fitting ADR 0019's remaining-gap
  direction.
