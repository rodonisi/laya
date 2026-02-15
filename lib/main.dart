import 'package:flutter/material.dart';
import 'package:fluvita/riverpod/report_queue.dart';
import 'package:fluvita/riverpod/repository/series_repository.dart';
import 'package:fluvita/riverpod/theme.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fluvita/riverpod/router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return EagerProviders(
      child: MaterialApp.router(
        title: 'Fluvita',
        debugShowCheckedModeBanner: false,
        theme: theme.lightTheme,
        darkTheme: theme.darkTheme,
        themeMode: theme.mode,
        routerConfig: ref.watch(routerProvider),
      ),
    );
  }
}

class EagerProviders extends ConsumerWidget {
  final Widget child;

  const EagerProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(queueWorkerProvider);

    return child;
  }
}
