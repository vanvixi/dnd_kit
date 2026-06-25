import 'package:flutter/material.dart';

import 'demos/basic_demo.dart';
import 'demos/multi_container/multi_container_demo.dart';

void main() => runApp(const ExampleGalleryApp());

@immutable
final class _DemoEntry {
  const _DemoEntry({
    required this.slug,
    required this.label,
    required this.hint,
    required this.icon,
    required this.builder,
  });

  /// Catalog slug; matches the docs concept and the Jaspr gallery.
  final String slug;
  final String label;
  final String hint;
  final IconData icon;
  final WidgetBuilder builder;
}

// Catalog order. Demos still to fill: collision, sensors, modifiers,
// auto-scroll, sortable, accessibility (see docs/product/examples-standard.md).
final _demos = <_DemoEntry>[
  _DemoEntry(
    slug: 'basic',
    label: 'Basic',
    hint: 'Drag, drop, handle, overlay',
    icon: Icons.drag_indicator,
    builder: (_) => const BasicDemo(),
  ),
  _DemoEntry(
    slug: 'multi-container',
    label: 'Multi-container',
    hint: 'Move cards across columns',
    icon: Icons.dashboard_customize_outlined,
    builder: (_) => const MultiContainerDemo(),
  ),
];

class ExampleGalleryApp extends StatelessWidget {
  const ExampleGalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'dnd_kit Examples',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff2563eb)),
        useMaterial3: true,
      ),
      home: const ExampleGalleryShell(),
    );
  }
}

class ExampleGalleryShell extends StatefulWidget {
  const ExampleGalleryShell({super.key});

  @override
  State<ExampleGalleryShell> createState() => _ExampleGalleryShellState();
}

class _ExampleGalleryShellState extends State<ExampleGalleryShell> {
  var _selectedIndex = 0;

  void _selectDemo(int index) {
    if (_selectedIndex == index) {
      return;
    }
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useWideLayout = constraints.maxWidth >= 900;
        final selectedDemo = _demos[_selectedIndex];
        final demo = KeyedSubtree(
          key: ValueKey<String>(selectedDemo.label),
          child: selectedDemo.builder(context),
        );

        if (useWideLayout) {
          return Scaffold(
            body: Row(
              children: [
                _GalleryRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _selectDemo,
                ),
                const VerticalDivider(width: 1),
                Expanded(child: demo),
              ],
            ),
          );
        }

        return Scaffold(
          body: demo,
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _selectDemo,
            destinations: [
              for (final demo in _demos)
                NavigationDestination(
                  icon: Icon(demo.icon),
                  label: demo.label,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _GalleryRail extends StatelessWidget {
  const _GalleryRail({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 232,
      child: NavigationRail(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        extended: true,
        leading: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          child: Row(
            children: [
              Icon(Icons.open_with, color: colorScheme.primary),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  'dnd_kit',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
        ),
        destinations: [
          for (final demo in _demos)
            NavigationRailDestination(
              icon: Icon(demo.icon),
              label: Text(demo.label),
            ),
        ],
      ),
    );
  }
}
