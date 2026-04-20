import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kover/models/read_direction.dart';
import 'package:kover/riverpod/providers/settings/image_reader_settings.dart';
import 'package:kover/utils/layout_constants.dart';
import 'package:kover/widgets/async_value.dart';
import 'package:kover/widgets/settings/choice_option.dart';
import 'package:kover/widgets/settings/numeric_option.dart';
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
    final provider = imageReaderSettingsProvider(seriesId: seriesId);
    return Async(
      asyncValue: ref.watch(provider),
      data: (settings) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: LayoutConstants.largePadding,
                    right: LayoutConstants.largePadding,
                    bottom: LayoutConstants.largePadding,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: LayoutConstants.largePadding,
                    children: [
                      Text(
                        'Reader Settings',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      ChoiceOption<ReadDirection>(
                        title: 'Reading Direction',
                        icon: settings.readDirection == .leftToRight
                            ? LucideIcons.chevronsRight
                            : LucideIcons.chevronsLeft,
                        options: const [
                          ChoiceOptionEntry(
                            value: ReadDirection.leftToRight,
                            label: 'Left to Right',
                            icon: LucideIcons.chevronsRight,
                          ),
                          ChoiceOptionEntry(
                            value: ReadDirection.rightToLeft,
                            label: 'Right to Left',
                            icon: LucideIcons.chevronsLeft,
                          ),
                        ],
                        value: settings.readDirection,
                        onChanged: (newValue) async {
                          if (newValue != settings.readDirection) {
                            await ref
                                .read(provider.notifier)
                                .toggleReadDirection();
                          }
                        },
                      ),
                      ChoiceOption<ReaderMode>(
                        title: 'Reader Mode',
                        icon: settings.readerMode == ReaderMode.vertical
                            ? LucideIcons.moveVertical
                            : LucideIcons.moveHorizontal,
                        options: const [
                          ChoiceOptionEntry(
                            value: ReaderMode.horizontal,
                            label: 'Horizontal',
                            icon: LucideIcons.moveHorizontal,
                          ),
                          ChoiceOptionEntry(
                            value: ReaderMode.vertical,
                            label: 'Vertical',
                            icon: LucideIcons.moveVertical,
                          ),
                        ],
                        value: settings.readerMode,
                        onChanged: (newValue) async {
                          if (newValue != settings.readerMode) {
                            await ref
                                .read(provider.notifier)
                                .toggleReaderMode();
                          }
                        },
                      ),
                      if (settings.readerMode == .horizontal) ...[
                        ChoiceOption<ImageScaleType>(
                          title: 'Fit Direction',
                          icon: settings.scaleType == ImageScaleType.fitWidth
                              ? LucideIcons.chevronsLeftRight
                              : LucideIcons.chevronsUpDown,
                          options: const [
                            ChoiceOptionEntry(
                              value: ImageScaleType.fitWidth,
                              label: 'Fit Width',
                              icon: LucideIcons.chevronsLeftRight,
                            ),
                            ChoiceOptionEntry(
                              value: ImageScaleType.fitHeight,
                              label: 'Fit Height',
                              icon: LucideIcons.chevronsUpDown,
                            ),
                          ],
                          value: settings.scaleType,
                          onChanged: (newValue) async {
                            if (newValue != settings.scaleType) {
                              await ref
                                  .read(provider.notifier)
                                  .toggleScaleType();
                            }
                          },
                        ),
                      ],
                      if (settings.readerMode == .vertical) ...[
                        NumericOption(
                          title: 'Margins',
                          icon: LucideIcons.panelLeftDashed,
                          value: settings.verticalReaderPadding,
                          min: ImageReaderSettingsLimits
                              .verticalReaderPaddingMin,
                          max: ImageReaderSettingsLimits
                              .verticalReaderPaddingMax,
                          step: ImageReaderSettingsLimits
                              .verticalReaderPaddingStep,
                          onChanged: (newValue) async => await ref
                              .read(provider.notifier)
                              .setVerticalReaderPadding(newValue),
                        ),
                        NumericOption(
                          title: 'Vertical Gap',
                          icon: LucideIcons.unfoldVertical,
                          value: settings.verticalReaderGap,
                          min: ImageReaderSettingsLimits.verticalReaderGapMin,
                          max: ImageReaderSettingsLimits.verticalReaderGapMax,
                          step: ImageReaderSettingsLimits.verticalReaderGapStep,
                          onChanged: (newValue) async => await ref
                              .read(provider.notifier)
                              .setVerticalReaderGap(newValue),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(
                left: LayoutConstants.largePadding,
                right: LayoutConstants.largePadding,
                bottom: LayoutConstants.largePadding,
                top: LayoutConstants.mediumPadding,
              ),
              child: Row(
                spacing: LayoutConstants.mediumPadding,
                crossAxisAlignment: .center,
                mainAxisAlignment: .center,
                children: [
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () async =>
                          await ref.read(provider.notifier).setDefault(),
                      icon: const Icon(LucideIcons.save),
                      label: const Text('Set Defaults'),
                    ),
                  ),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () async =>
                          await ref.read(provider.notifier).reset(),
                      icon: const Icon(LucideIcons.rotateCcw),
                      label: const Text('Reset'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
