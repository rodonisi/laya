import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:laya/riverpod/image_reader_settings.dart';

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
          icon: FaIcon(
            settings.readDirection == .leftToRight
                ? FontAwesomeIcons.anglesLeft
                : FontAwesomeIcons.anglesRight,
          ),
          tooltip: 'Read Direction',
          onPressed: () {
            ref
                .read(imageReaderSettingsProvider.notifier)
                .toggleReadDirection();
          },
        ),
        IconButton(
          icon: FaIcon(
            settings.scaleType == .fitWidth
                ? FontAwesomeIcons.arrowsLeftRight
                : FontAwesomeIcons.arrowsUpDown,
          ),
          tooltip: 'Fit Direction',
          onPressed: () {
            ref.read(imageReaderSettingsProvider.notifier).toggleScaleType();
          },
        ),
      ],
    );
  }
}
