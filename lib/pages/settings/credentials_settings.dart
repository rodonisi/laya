import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fluvita/riverpod/api/auth.dart';
import 'package:fluvita/riverpod/settings.dart';
import 'package:fluvita/utils/layout_constants.dart';
import 'package:fluvita/widgets/async_value.dart';

class CredentialsSettings extends HookConsumerWidget {
  const CredentialsSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final currentUser = ref.watch(currentUserProvider);
    final loginStatus = ref.watch(loginStatusProvider);

    return Card(
      margin: LayoutConstants.mediumEdgeInsets,
      child: Padding(
        padding: LayoutConstants.mediumEdgeInsets,
        child: Async(
          asyncValue: settings,
          data: (data) {
            final urlController = TextEditingController(text: data.url);
            final apiKeyController = TextEditingController(text: data.apiKey);

            return Column(
              mainAxisSize: .min,
              crossAxisAlignment: .start,
              spacing: LayoutConstants.mediumPadding,
              children: [
                Text(
                  'Credentials',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                TextField(
                  enabled: loginStatus != .loading,
                  controller: urlController,
                  decoration: InputDecoration(labelText: 'Base URL'),
                ),
                TextField(
                  enabled: loginStatus != .loading,
                  controller: apiKeyController,
                  decoration: InputDecoration(labelText: 'API Key'),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Async(
                      asyncValue: currentUser,
                      data: (user) {
                        final name = user.username;
                        final initials = name.isNotEmpty
                            ? name[0].toUpperCase()
                            : '?';

                        return Row(
                          children: [
                            CircleAvatar(child: Text(initials)),
                            const SizedBox(width: LayoutConstants.smallPadding),
                            Text(
                              name,
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium,
                            ),
                          ],
                        );
                      },
                      loading: () => SizedBox.square(
                        dimension: LayoutConstants.mediumIcon,
                        child: CircularProgressIndicator(),
                      ),
                      error: (_, _) => Icon(
                        FontAwesomeIcons.solidCircleXmark,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () {
                        ref
                            .read(settingsProvider.notifier)
                            .updateSetting(
                              SettingsState(
                                url: urlController.text,
                                apiKey: apiKeyController.text,
                              ),
                            );
                      },
                      label: const Text('Save'),
                      icon: const FaIcon(FontAwesomeIcons.solidFloppyDisk),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
