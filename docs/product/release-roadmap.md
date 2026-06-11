# Release Roadmap

## Phase 0 - Repo Foundation And Architecture Freeze

Set up the monorepo, package structure, coding conventions, API direction, and
basic validation commands.

First story: `docs/stories/phase-0-foundation/US-001-repository-foundation.md`.

## Phase 1 - Core Engine

Build the pure Dart foundation:

- stable IDs;
- geometry types;
- drag state machine;
- event models;
- collision detectors;
- modifier contracts;
- registry contracts;
- sensor contracts.

## Phase 2 - Basic Flutter Adapter

Create the first Flutter adapter surface:

- `DndScope`;
- `DndController`;
- `DndDraggable`;
- `DndDroppable`;
- Flutter registry integration;
- basic measuring;
- drag event lifecycle.

## Phase 3 - Sensors And Activation

Support pointer, mouse, touch, long press, drag handles, and keyboard input.

## Phase 4 - Measuring, Collision Runtime, And Modifiers

Harden coordinate-space measuring, collision runtime behavior, custom collision
detectors, modifier composition, and cached measuring.

## Phase 5 - Overlay, Visual State, And Auto-Scroll

Complete drag overlay, draggable/droppable visual state, and common auto-scroll
behavior.

## Phase 6 - Stable Sortable Preset

Provide sortable vertical list, horizontal list, and grid APIs.

## Phase 7 - Kanban Showcase And Experimental Multi-Container

Use Kanban as a realistic proof that the generic engine supports complex UIs.

## Phase 8 - Production Hardening

Add diagnostics, performance baselines, cross-platform verification, docs, and
release-quality checks.

First story: `docs/stories/phase-8-production-hardening/US-031-release-quality-workspace-validation.md`.

Package polish before release also collapses the old umbrella-only `dnd_kit`
role into the primary Flutter package through
`docs/stories/phase-8-production-hardening/US-035-main-package-rename-and-umbrella-collapse.md`.

## Phase 9 - V1 Release Readiness

Prepare the renamed package for external review and publication:

- package-facing README and changelog;
- public API documentation polish;
- stale example documentation cleanup;
- publish dry-run and release metadata checks.

First story: `docs/stories/phase-9-release-readiness/US-036-docs-api-polish-before-release.md`.

## Phase 10 - Post-Publish Adoption

Improve the package after the first pub.dev publication by closing package
score gaps, keeping release metadata verifiable, and making adoption paths
clear for users.

First story: `docs/stories/phase-10-post-publish-adoption/US-037-pubdev-quality-package-example-pass.md`.
