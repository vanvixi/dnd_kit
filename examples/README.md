# Examples

Example apps are added story by story as behavior becomes real. The demo
catalog, naming, layout, and Flutter/Jaspr parity target are defined in the
[Examples Standard](../docs/product/examples-standard.md).

## Two galleries

`examples/` holds exactly two projects:

- `examples/flutter_example_gallery` — the Flutter gallery.
- `examples/jaspr_example_gallery` — the Jaspr gallery.

Both expose the canonical demo catalog (`basic`, `collision`, `sensors`,
`modifiers`, `auto-scroll`, `sortable`, `multi-container`, `accessibility`).
Each demo lives under `lib/demos/` as a single `<slug>_demo.dart` file, or as a
`<slug>/` subfolder when it needs several files. Demos still missing on an
adapter are tracked parity gaps, not permitted differences — see the standard
for the current matrix.

The Flutter gallery ships the full catalog. The Jaspr gallery ships everything
except `multi-container`, which is the last remaining parity gap.
