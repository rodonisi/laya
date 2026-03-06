import 'package:flutter/material.dart';
import 'package:fluvita/pages/settings/credentials_settings.dart';
import 'package:fluvita/pages/settings/theme_settings.dart';
import 'package:fluvita/widgets/sliver_bottom_padding.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: Text('Settings'),
            ),
            SliverToBoxAdapter(child: CredentialsSettings()),
            SliverToBoxAdapter(child: ThemeSettings()),
            SliverBottomPadding(),
          ],
        ),
      ),
    );
  }
}
