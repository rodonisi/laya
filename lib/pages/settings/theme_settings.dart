import 'package:flutter/material.dart';
import 'package:fluvita/pages/settings/choice_settings_entry.dart';
import 'package:fluvita/pages/settings/number_settings_entry.dart';
import 'package:fluvita/pages/settings/switch_settings_entry.dart';
import 'package:fluvita/riverpod/providers/settings/download_settings.dart';
import 'package:fluvita/widgets/async_value.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fluvita/riverpod/providers/theme.dart' hide Theme;
import 'package:fluvita/utils/layout_constants.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
          spacing: LayoutConstants.smallPadding,
          children: [
            Text(
              'General',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            ChoiceSettingsEntry<ThemeMode>(
              title: 'Theme Mode',
              segments: const [
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.system,
                  label: Text('System'),
                  icon: Icon(
                    LucideIcons.sunMoon,
                    size: LayoutConstants.smallIcon,
                  ),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.light,
                  label: Text('Light'),
                  icon: Icon(
                    LucideIcons.sun,
                    size: LayoutConstants.smallIcon,
                  ),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.dark,
                  label: Text('Dark'),
                  icon: Icon(
                    LucideIcons.moon,
                    size: LayoutConstants.smallIcon,
                  ),
                ),
              ],
              selected: theme.mode,
              onSelectionChanged: (newSelection) {
                ref.read(themeProvider.notifier).setMode(newSelection);
              },
            ),
            SwitchSettingsEntry(
              title: 'Outlined Theme',
              value: theme.outlined,
              onChanged: (value) =>
                  ref.read(themeProvider.notifier).setOutlined(value),
            ),
            Async(
              asyncValue: ref.watch(downloadSettingsProvider),
              data: (data) => NumberSettingsEntry(
                title: 'Max Concurrent Downloads',
                value: data.concurrentDownloads,
                onChanged: (value) {
                  ref
                      .read(downloadSettingsProvider.notifier)
                      .setConcurrentDownloads(value);
                },
                min: 1,
                max: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
