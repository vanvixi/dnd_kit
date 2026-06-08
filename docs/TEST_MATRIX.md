# Test Matrix

This file maps product behavior to proof.

Do not mark a row implemented until tests or validation evidence exist.

## Status Values

| Status | Meaning |
| --- | --- |
| planned | Accepted as intended behavior, not implemented |
| in_progress | Actively being built |
| implemented | Implemented and proof exists |
| changed | Contract changed after earlier implementation |
| retired | No longer part of the product contract |

## Matrix

| Story | Contract | Unit | Integration | E2E | Platform | Status | Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- |
| US-001 | Repository foundation and package boundaries | yes | no | no | no | implemented | `story verify US-001`; `fvm dart analyze`; `melos run analyze` |
| US-002 | Melos workspace tooling upgraded to `^7.8.1` | yes | yes | no | no | implemented | `story verify US-002`; `melos bootstrap`; `melos run analyze` |

## Evidence Rules

- Unit proof covers pure domain and application rules.
- Integration proof covers backend enforcement, data integrity, provider
  behavior, jobs, or service contracts.
- E2E proof covers user-visible browser flows.
- Platform proof covers only shell, deployment, mobile, desktop, or runtime
  behavior that cannot be proven in lower layers.
- A story can be implemented without every proof column if the story packet
  explains why.
