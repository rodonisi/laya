import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fluvita/riverpod/providers/settings/image_reader_settings.dart'
    show
        ImageReaderSettingsLimits,
        ImageScaleType,
        ReaderMode,
        imageReaderSettingsProvider;
import 'package:fluvita/models/read_direction.dart';
import 'package:fluvita/utils/layout_constants.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ImageReaderControls extends ConsumerWidget {
  final int seriesId;
  const ImageReaderControls({super.key, required this.seriesId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(LucideIcons.slidersHorizontal),
      tooltip: 'Reader Settings',
      onPressed: () {
        showModalBottomSheet(
          context: context,
          showDragHandle: true,
          isScrollControlled: true,
          builder: (context) =>
              _ImageReaderSettingsBottomSheet(seriesId: seriesId),
        );
      },
    );
  }
}

class _ImageReaderSettingsBottomSheet extends ConsumerWidget {
  final int seriesId;

  const _ImageReaderSettingsBottomSheet({required this.seriesId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(imageReaderSettingsProvider(seriesId: seriesId));
    final notifier = ref.read(
      imageReaderSettingsProvider(seriesId: seriesId).notifier,
    );
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(
          left: LayoutConstants.mediumPadding,
          right: LayoutConstants.mediumPadding,
          bottom: LayoutConstants.largePadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: LayoutConstants.mediumPadding,
          children: [
            Text(
              'Reader Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Row(
              children: [
                const Expanded(child: Text('Read Direction')),
                SegmentedButton<ReadDirection>(
                  segments: const [
                    ButtonSegment<ReadDirection>(
                      value: ReadDirection.leftToRight,
                      label: Text('LTR'),
                      icon: Icon(LucideIcons.chevronsRight),
                    ),
                    ButtonSegment<ReadDirection>(
                      value: ReadDirection.rightToLeft,
                      label: Text('RTL'),
                      icon: Icon(LucideIcons.chevronsLeft),
                    ),
                  ],
                  selected: {settings.readDirection},
                  onSelectionChanged: (Set<ReadDirection> newSelection) {
                    if (newSelection.first != settings.readDirection) {
                      notifier.toggleReadDirection();
                    }
                  },
                ),
              ],
            ),
            Row(
              children: [
                const Expanded(child: Text('Reader Mode')),
                SegmentedButton<ReaderMode>(
                  segments: const [
                    ButtonSegment<ReaderMode>(
                      value: ReaderMode.vertical,
                      label: Text('Vertical'),
                      icon: Icon(LucideIcons.moveVertical),
                    ),
                    ButtonSegment<ReaderMode>(
                      value: ReaderMode.horizontal,
                      label: Text('Horizontal'),
                      icon: Icon(LucideIcons.moveHorizontal),
                    ),
                  ],
                  selected: {settings.readerMode},
                  onSelectionChanged: (Set<ReaderMode> newSelection) {
                    if (newSelection.first != settings.readerMode) {
                      notifier.toggleReaderMode();
                    }
                  },
                ),
              ],
            ),
            if (settings.readerMode == ReaderMode.vertical) ...[
              _SettingRow(
                label: 'Vertical Gap',
                value: settings.verticalReaderGap.toStringAsFixed(1),
                increaseIcon: LucideIcons.unfoldVertical,
                decreaseIcon: LucideIcons.foldVertical,
                onDecrease:
                    settings.verticalReaderGap >
                        ImageReaderSettingsLimits.verticalReaderGapMin
                    ? () => notifier.decreaseVerticalReaderGap()
                    : null,
                onIncrease:
                    settings.verticalReaderGap <
                        ImageReaderSettingsLimits.verticalReaderGapMax
                    ? () => notifier.increaseVerticalReaderGap()
                    : null,
              ),
              _SettingRow(
                label: 'Side Padding',
                value: settings.verticalReaderPadding.toStringAsFixed(1),
                increaseIcon: LucideIcons.arrowRightFromLine,
                decreaseIcon: LucideIcons.arrowLeftToLine,
                onDecrease:
                    settings.verticalReaderPadding >
                        ImageReaderSettingsLimits.verticalReaderPaddingMin
                    ? () => notifier.decreaseVerticalReaderPadding()
                    : null,
                onIncrease:
                    settings.verticalReaderPadding <
                        ImageReaderSettingsLimits.verticalReaderPaddingMax
                    ? () => notifier.increaseVerticalReaderPadding()
                    : null,
              ),
            ] else
              Row(
                children: [
                  const Expanded(child: Text('Fit Direction')),
                  SegmentedButton<ImageScaleType>(
                    segments: const [
                      ButtonSegment<ImageScaleType>(
                        value: ImageScaleType.fitWidth,
                        label: Text('Fit Width'),
                        icon: Icon(LucideIcons.chevronsLeftRight),
                      ),
                      ButtonSegment<ImageScaleType>(
                        value: ImageScaleType.fitHeight,
                        label: Text('Fit Height'),
                        icon: Icon(LucideIcons.chevronsUpDown),
                      ),
                    ],
                    selected: {settings.scaleType},
                    onSelectionChanged: (Set<ImageScaleType> newSelection) {
                      if (newSelection.first != settings.scaleType) {
                        notifier.toggleScaleType();
                      }
                    },
                  ),
                ],
              ),
            Row(
              spacing: LayoutConstants.mediumPadding,
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: notifier.setDefault,
                    icon: const Icon(LucideIcons.save),
                    label: const Text('Use as Defaults'),
                  ),
                ),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: notifier.reset,
                    icon: const Icon(LucideIcons.rotateCcw),
                    label: const Text('Reset to Defaults'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.label,
    required this.value,
    required this.increaseIcon,
    required this.decreaseIcon,
    required this.onDecrease,
    required this.onIncrease,
  });

  final String label;
  final String value;
  final IconData increaseIcon;
  final IconData decreaseIcon;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label),
              Text(
                value,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: onDecrease,
          icon: Icon(decreaseIcon),
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          onPressed: onIncrease,
          icon: Icon(increaseIcon),
        ),
      ],
    );
  }
}
