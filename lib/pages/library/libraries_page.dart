import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fluvita/riverpod/api/library.dart';
import 'package:fluvita/riverpod/router.dart';

class LibraryPage extends ConsumerWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libs = ref.watch(librariesProvider);

    return libs.when(
      data: (libraries) => ListView.builder(
        itemCount: libraries.length,
        itemBuilder: (context, index) {
          final lib = libraries[index];
          return ListTile(
            title: Text(lib.name),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => SeriesRoute(libraryId: lib.id).push(context),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
