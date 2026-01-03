import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:laya/riverpod/theme.dart' hide Theme;
import 'package:laya/utils/layout_constants.dart';

class ThemeSettings extends ConsumerWidget {
  const ThemeSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return Card(
      margin: LayoutConstants.mediumEdgeInsets,
      child: Padding(
        padding: LayoutConstants.mediumEdgeInsets,
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Theme',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: LayoutConstants.mediumPadding),
            Text(
              'Theme Mode',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: LayoutConstants.smallPadding),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.system,
                    label: Text('System'),
                    icon: Icon(
                      FontAwesomeIcons.circleHalfStroke,
                      size: LayoutConstants.smallIcon,
                    ),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.light,
                    label: Text('Light'),
                    icon: Icon(
                      FontAwesomeIcons.solidSun,
                      size: LayoutConstants.smallIcon,
                    ),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.dark,
                    label: Text('Dark'),
                    icon: Icon(
                      FontAwesomeIcons.solidMoon,
                      size: LayoutConstants.smallIcon,
                    ),
                  ),
                ],
                selected: {theme.mode},
                onSelectionChanged: (Set<ThemeMode> newSelection) {
                  ref.read(themeProvider.notifier).setMode(newSelection.first);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
