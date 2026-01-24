import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fluvita/riverpod/image_reader_settings.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ImageReaderControls extends ConsumerWidget {
  const ImageReaderControls({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(imageReaderSettingsProvider);

    return Row(
      mainAxisAlignment: .spaceEvenly,
      children: [
        IconButton(
          icon: Icon(
            settings.readDirection == .leftToRight
                ? LucideIcons.chevronsLeft
                : LucideIcons.chevronsRight,
          ),
          tooltip: 'Read Direction',
          onPressed: () {
            ref
                .read(imageReaderSettingsProvider.notifier)
                .toggleReadDirection();
          },
        ),
        if (settings.readerMode == .vertical) ...[
          IconButton(
            icon: Icon(LucideIcons.foldVertical),
            tooltip: 'Decrease gap',
            onPressed: settings.verticalImageGap > 0.0
                ? () {
                    ref
                        .read(imageReaderSettingsProvider.notifier)
                        .setVerticalImageGap(
                          (settings.verticalImageGap - 4).clamp(0.0, 64.0),
                        );
                  }
                : null,
          ),
          IconButton(
            icon: Icon(LucideIcons.unfoldVertical),
            tooltip: 'Increase gap',
            onPressed: settings.verticalImageGap < 64.0
                ? () {
                    ref
                        .read(imageReaderSettingsProvider.notifier)
                        .setVerticalImageGap(
                          (settings.verticalImageGap + 4).clamp(0.0, 64.0),
                        );
                  }
                : null,
          ),
        ] else
          IconButton(
            icon: Icon(
              settings.scaleType == .fitWidth
                  ? LucideIcons.chevronsLeftRight
                  : LucideIcons.chevronsUpDown,
            ),
            tooltip: 'Fit Direction',
            onPressed: () {
              ref.read(imageReaderSettingsProvider.notifier).toggleScaleType();
            },
          ),
        IconButton(
          icon: Icon(
            settings.readerMode == .vertical
                ? LucideIcons.moveVertical
                : LucideIcons.moveHorizontal,
          ),
          tooltip: 'Reader Mode',
          onPressed: () {
            ref.read(imageReaderSettingsProvider.notifier).toggleReaderMode();
          },
        ),
      ],
    );
  }
}
