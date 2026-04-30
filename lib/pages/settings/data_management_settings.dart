import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kover/riverpod/providers/settings/download_settings.dart';
import 'package:kover/riverpod/repository/database.dart';
import 'package:kover/utils/layout_constants.dart';
import 'package:kover/widgets/async_value.dart';
import 'package:kover/widgets/settings/boolean_option.dart';
import 'package:kover/widgets/settings/numeric_option.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DataManagementSettings extends ConsumerWidget {
  const DataManagementSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(downloadSettingsProvider);

    return Card(
      margin: LayoutConstants.mediumEdgeInsets,
      child: Padding(
        padding: LayoutConstants.mediumEdgeInsets,
        child: Async(
          asyncValue: settings,
          data: (data) => Column(
            mainAxisSize: .min,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: LayoutConstants.largePadding,
            children: [
              Text(
                'Data Management',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              BooleanOption(
                title: 'Download All Covers',
                description:
                    'If disabled, covers will only be downloaded together with chapters. '
                    'Covers will still be fetched from the server on demand when not downloaded and a connection is available.',
                icon: LucideIcons.imageDownDir,
                value: data.downloadCovers,
                onChanged: (value) async {
                  await ref
                      .read(downloadSettingsProvider.notifier)
                      .setDownloadCovers(value);
                },
              ),
              NumericOption(
                title: 'Max Concurrent Downloads',
                icon: LucideIcons.download,
                min: 1,
                max: 10,
                step: 1,
                decimalPlaces: 0,
                value: data.concurrentDownloads.toDouble(),
                onChanged: (value) async {
                  await ref
                      .read(downloadSettingsProvider.notifier)
                      .setConcurrentDownloads(value.round());
                },
              ),
              Wrap(
                spacing: LayoutConstants.mediumPadding,
                runSpacing: LayoutConstants.mediumPadding,
                alignment: .center,
                children: [
                  DatabaseClearOperationButton(
                    asyncValue: ref.watch(reclaimSpaceProvider),
                    startText: 'Reclaim Space',
                    startIcon: const Icon(LucideIcons.databaseZap),
                    onStart: () async {
                      await ref
                          .read(reclaimSpaceProvider.notifier)
                          .reclaimSpace();
                    },
                  ),
                  DatabaseClearOperationButton(
                    asyncValue: ref.watch(clearDownloadsProvider),
                    startText: 'Clear Downloads',
                    startIcon: const Icon(Icons.file_download_off),
                    onStart: () async {
                      await ref
                          .read(clearDownloadsProvider.notifier)
                          .clearDownloads();
                    },
                  ),
                  DatabaseClearOperationButton(
                    asyncValue: ref.watch(clearCoversProvider),
                    startText: 'Clear Covers',
                    startIcon: const Icon(LucideIcons.imageOff),
                    onStart: () async {
                      await ref
                          .read(clearCoversProvider.notifier)
                          .clearCovers();
                    },
                  ),
                  DatabaseClearOperationButton(
                    asyncValue: ref.watch(clearDatabaseProvider),
                    startText: 'Clear Database',
                    startIcon: const Icon(LucideIcons.trash),
                    onStart: () async {
                      await ref
                          .read(clearDatabaseProvider.notifier)
                          .clearDatabase();
                    },
                  ),
                ],
              ),
              const Row(
                mainAxisAlignment: .start,
                children: [
                  DatabaseSize(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DatabaseClearOperationButton extends ConsumerWidget {
  final AsyncValue<ClearOperationStatus> asyncValue;
  final String startText;
  final Icon? startIcon;
  final VoidCallback onStart;

  const DatabaseClearOperationButton({
    super.key,
    required this.asyncValue,
    required this.startText,
    required this.onStart,
    this.startIcon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Async(
      asyncValue: asyncValue,
      data: (status) {
        return switch (status) {
          .idle => FilledButton.icon(
            onPressed: () {
              onStart();
            },
            icon: startIcon,
            label: Text(startText),
          ),
          .busy => Tooltip(
            message: 'Database busy...',
            triggerMode: .tap,
            child: FilledButton.icon(
              onPressed: null,
              icon: const SizedBox.square(
                dimension: LayoutConstants.smallIcon,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              label: Text(startText),
            ),
          ),
          .inProgress => FilledButton.icon(
            onPressed: null,
            icon: const SizedBox.square(
              dimension: LayoutConstants.smallIcon,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            label: const Text('Executing'),
          ),
          .reclaimingSpace => FilledButton.icon(
            onPressed: null,
            icon: const SizedBox.square(
              dimension: LayoutConstants.smallIcon,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            label: const Text('Reclaiming Space'),
          ),
          .error => FilledButton.icon(
            onPressed: () async {
              onStart();
            },
            icon: Icon(
              LucideIcons.circleX,
              color: Theme.of(context).colorScheme.error,
            ),
            label: const Text('Retry'),
          ),
        };
      },
    );
  }
}

class DatabaseSize extends ConsumerWidget {
  const DatabaseSize({
    super.key,
  });

  String _formatSize(int sizeInBytes) {
    if (sizeInBytes > 1024 * 1024 * 1024) {
      return '${(sizeInBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }

    if (sizeInBytes > 1024 * 1024) {
      return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }

    if (sizeInBytes > 1024) {
      return '${(sizeInBytes / 1024).toStringAsFixed(2)} KB';
    }

    return '$sizeInBytes B';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: .min,
      mainAxisAlignment: .start,
      children: [
        Text('Database Size: ', style: Theme.of(context).textTheme.labelMedium),
        Async(
          asyncValue: ref.watch(databaseSizeProvider),
          data: (size) {
            return Text(
              _formatSize(size),
              style: Theme.of(context).textTheme.labelMedium,
            );
          },
          loading: () => const SizedBox.square(
            dimension: LayoutConstants.smallIcon,
            child: CircularProgressIndicator(),
          ),
        ),
      ],
    );
  }
}
