import 'package:flutter/material.dart';
import 'package:fluvita/riverpod/settings.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fluvita/riverpod/router.dart';
import 'package:fluvita/riverpod/api/auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fluvita/utils/layout_constants.dart';

class LoginGuard extends ConsumerWidget {
  final Widget child;

  const LoginGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginStatus = ref.watch(loginStatusProvider);

    return switch (loginStatus) {
      .loggedIn => child,
      .loading => const Center(child: CircularProgressIndicator()),
      .noCredentials => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(
                FontAwesomeIcons.userLock,
                size: LayoutConstants.largerIcon,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: LayoutConstants.smallPadding),
              Text(
                'Not Signed In',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: LayoutConstants.smallerPadding),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: LayoutConstants.mediumPadding,
                ),
                child: const Text(
                  'No credentials configured. Please add your server URL and API key in Settings.',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: LayoutConstants.smallPadding),
              FilledButton(
                onPressed: () => SettingsRoute().go(context),
                child: const Text('Open Settings'),
              ),
            ],
          ),
        ),
      ),
      .error => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(
                FontAwesomeIcons.triangleExclamation,
                size: LayoutConstants.largerIcon,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: LayoutConstants.smallPadding),
              Text(
                'Connection Error',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: LayoutConstants.smallerPadding),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: LayoutConstants.mediumPadding,
                ),
                child: const Text(
                  'Failed to fetch user. Please check your credentials or try again.',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: LayoutConstants.smallPadding),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FilledButton.icon(
                    onPressed: () => ref.invalidate(currentUserProvider),
                    icon: FaIcon(
                      FontAwesomeIcons.rotateRight,
                      size: LayoutConstants.smallIcon,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    label: const Text('Retry'),
                  ),
                  const SizedBox(height: LayoutConstants.smallPadding),
                  FilledButton.icon(
                    onPressed: () => SettingsRoute().go(context),
                    icon: FaIcon(
                      FontAwesomeIcons.gear,
                      size: LayoutConstants.smallIcon,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    label: const Text('Open Settings'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    };
  }
}
