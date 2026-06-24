# Exec Plan

## Goal

Define and deliver a production-ready multi-container feature for the `dnd_kit`
family: the library owns default interaction semantics and adapter-level
surface area, while applications keep ownership of presentation and data
mutation.

## Scope

In scope:

- graduate multi-container beyond helper-only experimental status;
- define library-owned default interaction semantics for cross-container target
  resolution and insertion behavior;
- provide adapter-level multi-container APIs for Flutter and Jaspr so app code
  does not need to assemble raw droppables, custom collision ranking, and
  drag-end move logic for the common board/list case;
- preserve explicit override hooks for applications that need product-specific
  interaction policy;
- keep presentation, animation, and application state mutation outside the
  library;
- define the validation and release expectations required for a supported
  production feature.

Out of scope:

- forcing a single visual design system, animation style, or layout on apps;
- deeply nested sortable trees, virtualization policy, or cross-window drag;
- mutating user-owned collections inside the library;
- removing all lower-level primitives for advanced adopters.

## Risk Classification

Risk flags:

- Public contracts.
- Cross-platform.
- Existing behavior.
- Weak proof.
- Multi-domain.

Hard gates:

- None from the intake hard-gate list, but this story is high-risk because it
  changes supported public behavior across the shared engine and both adapters.

## Work Phases

1. Discovery.
2. Design.
3. Validation planning.
4. Implementation.
5. Verification.
6. Harness update.

## Stop Conditions

Pause for human confirmation if:

- the team cannot agree on which interaction semantics belong in the default
  policy versus override hooks;
- the production-ready contract would require weakening app-owned presentation
  or mutation boundaries;
- adapter parity would require different default behavior between Flutter and
  Jaspr;
- the feature should remain experimental after all rather than graduate to a
  supported surface.
