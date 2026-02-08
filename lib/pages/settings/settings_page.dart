import 'package:flutter/material.dart';
import 'package:fluvita/pages/settings/credentials_settings.dart';
import 'package:fluvita/pages/settings/theme_settings.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ListView(
        children: const [
          CredentialsSettings(),
          ThemeSettings(),
        ],
      ),
    );
  }
}
