import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../data/site_data.dart';

/// The package family, drawn as a hierarchy: the `dnd_kit` engine on top
/// powering the two adapters below, so it reads at a glance that one engine
/// drives both. Each card links to its pub.dev page.
class Packages extends StatelessComponent {
  const Packages({super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: 'mx-auto flex max-w-3xl flex-col items-center', [
      // The engine, centered above the gap between the two adapters.
      div(classes: 'flex w-full justify-center', [
        div(classes: 'w-full max-w-sm', [_card(enginePackage)]),
      ]),

      // Mobile: a single stem (cards stack vertically below).
      div(classes: 'h-6 w-px bg-line sm:hidden', const []),

      // Desktop: a branching connector — a short stem from the engine, a
      // horizontal bar, then a drop into the center of each adapter card. The
      // adapters use a no-gap 2-column grid so their centers sit exactly at
      // 25% / 75%, which the bar ends and drops line up with.
      div(classes: 'relative hidden h-12 w-full sm:block', [
        // Stem: engine bottom → bar center.
        div(
          classes: 'absolute left-1/2 top-0 h-6 w-px -translate-x-1/2 bg-line',
          const [],
        ),
        // Horizontal bar between the two card centers.
        div(
          classes: 'absolute left-1/4 right-1/4 top-6 h-px bg-line',
          const [],
        ),
        // Drops to each card center.
        div(
          classes:
              'absolute left-1/4 top-6 h-6 w-px -translate-x-1/2 bg-line',
          const [],
        ),
        div(
          classes:
              'absolute right-1/4 top-6 h-6 w-px translate-x-1/2 bg-line',
          const [],
        ),
        // "powers" label sitting on the bar's midpoint.
        div(
          classes:
              'absolute left-1/2 top-6 -translate-x-1/2 -translate-y-1/2 '
              'bg-paper px-2',
          [
            span(
              classes:
                  'font-mono text-[10px] uppercase tracking-wider text-accent',
              const [.text('powers')],
            ),
          ],
        ),
      ]),

      // The adapters: no gap so each cell center is exactly 25% / 75%; spacing
      // comes from per-cell padding instead.
      div(
        classes: 'grid w-full grid-cols-1 gap-4 sm:grid-cols-2 sm:gap-0',
        [
          for (final pkg in adapterPackages)
            div(classes: 'sm:px-3', [_card(pkg)]),
        ],
      ),
    ]);
  }

  Component _card(Package pkg) {
    final accent = pkg.isEngine;
    return a(
      href: pkg.href,
      target: Target.blank,
      attributes: const {'rel': 'noreferrer'},
      classes:
          'group flex h-full w-full flex-col gap-3 rounded-2xl border p-5 '
          'transition-colors '
          '${accent ? 'border-accent/50 bg-accent/5 hover:border-accent' : 'border-line bg-surface hover:border-accent/50'}',
      [
        div(classes: 'flex items-center justify-between gap-3', [
          span(
            classes: 'font-mono text-lg text-ink',
            [.text(pkg.name)],
          ),
          span(
            classes: accent
                ? 'rounded-full bg-accent px-2.5 py-0.5 font-mono text-[10px] '
                      'uppercase tracking-wider text-white'
                : 'rounded-full border border-line px-2.5 py-0.5 font-mono '
                      'text-[10px] uppercase tracking-wider text-muted',
            [.text(pkg.role)],
          ),
        ]),
        p(classes: 'text-sm leading-relaxed text-muted', [.text(pkg.body)]),
        span(
          classes:
              'text-sm font-medium text-accent transition-transform '
              'group-hover:translate-x-0.5',
          const [.text('View on pub.dev →')],
        ),
      ],
    );
  }
}
