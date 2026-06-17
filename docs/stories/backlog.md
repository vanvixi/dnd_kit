# Story Backlog

This backlog will be populated after a user provides a project spec or selects a
specific initiative.

Do not create every possible story packet up front. Create story packets when
the work is selected or when a product decision needs a durable place to land.

## Candidate Epics

| Epic | Description | Status |
| --- | --- | --- |
| Jaspr multi-container sortable | Bring `SortableContainer` / `SortableMultiContainer` to `dnd_kit_jaspr` for cross-container sorting parity with Flutter. These helpers are framework-neutral pure Dart but currently live only in `dnd_kit_flutter`; preferred path is hoisting them into the `dnd_kit` engine (engine + both adapters republish), per ADR 0019's remaining-gap note. Deferred from US-062. | unsliced |
