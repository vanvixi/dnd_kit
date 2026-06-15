# 0012 Unified Touch Activation Haptics

Date: 2026-06-15

## Status

Accepted

## Context

US-040 made default touch activation delayed so drags can coexist with
scrollable lazy lists. Explicit `DndLongPressActivation` could optionally emit
haptic feedback, but the new default delayed touch path had no tactile pickup
cue. Keeping haptic feedback attached to long-press activation would make the
same touch drag feel different depending on which activation path started it.

The existing `DndLongPressActivation.hapticFeedback` setting also put feedback
configuration inside an activation timing object. That made it possible for
haptic policy to conflict across places instead of being resolved as a single
draggable behavior.

## Decision

Touch drag activation emits one `HapticFeedback.selectionClick()` pulse by
default when the drag starts. This applies to the platform-adaptive default
delayed touch activation and to explicit `longPressActivation`.

Haptic feedback is resolved most-specific-first:

```text
DndDraggable.enableHapticFeedback
  -> DndScope.enableHapticFeedback (non-null, defaults to true)
    -> library default true
```

Mouse, trackpad, and keyboard activations emit no haptic feedback. The
`DndLongPressActivation.hapticFeedback` field is removed; long-press haptic
behavior is governed by the unified draggable/scope resolution.

## Alternatives Considered

1. Keep `DndLongPressActivation.hapticFeedback` and add a second default-touch
   setting. Rejected because users would have two authorities for one feedback
   outcome.
2. Put haptic feedback on `DndSensorActivationConstraint`. Rejected because
   activation constraints decide when a drag starts, not what feedback should
   accompany a started drag.
3. Disable haptic feedback by default. Rejected because touch pickup should
   feel physical on mobile and Flutter's haptic API is safe as a no-op on
   platforms without a haptic engine.

## Consequences

Positive:

- Default touch drags and explicit long-press touch drags feel consistent.
- Applications can disable haptics once at a scope or override a specific
  draggable.
- A non-null default `DndScope` value makes the default touch haptic policy
  explicit in the scope API.
- Activation timing and feedback policy stay separate.

Tradeoffs:

- This is a breaking pre-1.0 API change for code using
  `DndLongPressActivation.hapticFeedback`.
- Touch activation now calls the platform haptic channel by default, though
  Flutter treats unsupported platforms as a no-op.

## Follow-Up

- Document the unified haptic resolution in API principles and CHANGELOG.
- Cover the default touch, long-press, mouse, keyboard, widget override, and
  scope default paths with widget tests.
