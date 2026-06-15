# 0011 Owner-Aware Registry Registration

Date: 2026-06-15

## Status

Accepted

## Context

US-040 made draggables work inside lazy `ListView.builder` lists. A real crash
was reported on macOS: with a tall column showing one item, dragging the first
item to the bottom auto-scrolls the list, and the registry threw
`Duplicate draggable/droppable id` (US-033's debug assertion). The cause is
inherent to lazy slivers: when a keyed item shifts position or re-enters the
viewport, the new element mounts (and registers) before the old element is
disposed (and unregisters). A synchronous duplicate assertion cannot tell this
benign transient apart from a genuine bug, and `findChildIndexCallback` does not
cover the auto-scroll + frequent rebuild case.

## Decision

Make registry registration owner-aware. `registerDraggable`/`registerDroppable`
and their unregister counterparts accept an optional `owner` (the registering
widget state):

- With `owner`: registration is last-wins and records the current owner. A
  departing owner whose id was already taken over by a newer owner does not
  remove the live registration. No synchronous duplicate detection runs.
- Without `owner`: unchanged strict behavior — duplicate ids emit a warning and
  trip a debug assertion. This preserves US-033 diagnostics for direct
  `DndRegistry` use and its tests.

`DndDraggable` and `DndDroppable` pass `owner: this`. As a consequence,
`findChildIndexCallback` becomes a performance recommendation, not a correctness
requirement, for lazy reorderable lists.

## Alternatives Considered

1. Require `findChildIndexCallback` in all lazy lists — rejected: does not cover
   auto-scroll/rebuild transients and pushes a sharp edge onto adopters.
2. Demote the duplicate assertion to a warning for all callers — rejected:
   weakens US-033 diagnostics even for direct registry misuse.
3. Owner sets plus a deferred post-frame duplicate check to keep widget-level
   detection — deferred as a possible follow-up; heavier and not needed to fix
   the crash.

## Consequences

Positive:

- Draggables/sortables inside lazy lists no longer crash on reconciliation
  transients, including auto-scroll during a drag.
- A stale element cannot remove a live registration mid-recycle.
- Strict duplicate diagnostics remain for direct registry use.

Tradeoffs:

- Widget-registered ids no longer raise a synchronous duplicate-id
  warning/assertion (owner mode is last-wins); genuine duplicate ids in widgets
  are silently last-wins until a deferred check is added.
- `dnd_kit_core` public API gains an optional `owner` parameter (additive,
  source-compatible); bumped to `0.1.0-dev.2`.

## Follow-Up

- Consider a deferred post-frame duplicate check to restore widget-level
  duplicate diagnostics for persistent duplicates.
