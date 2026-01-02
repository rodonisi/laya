import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:laya/riverpod/epub_reader_settings.dart';
import 'package:laya/utils/layout_constants.dart';

class EpubReaderControls extends ConsumerWidget {
  const EpubReaderControls({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(epubReaderSettingsProvider);

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
            ref.read(epubReaderSettingsProvider.notifier).toggleReadDirection();
          },
        ),
        IconButton(
          icon: FaIcon(FontAwesomeIcons.font),
          iconSize: LayoutConstants.smallIcon,
          tooltip: 'Decrease Font Size',
          onPressed: settings.canDecreaseFontSize
              ? () {
                  ref
                      .read(epubReaderSettingsProvider.notifier)
                      .decreaseFontSize();
                }
              : null,
        ),
        IconButton(
          icon: FaIcon(FontAwesomeIcons.font),
          tooltip: 'Increase Font Size',
          onPressed: settings.canIncreaseFontSize
              ? () {
                  ref
                      .read(epubReaderSettingsProvider.notifier)
                      .increaseFontSize();
                }
              : null,
        ),
        IconButton(
          icon: FaIcon(FontAwesomeIcons.arrowsLeftRight),
          iconSize: LayoutConstants.smallIcon,
          tooltip: 'Decrease Margin Size',
          onPressed: settings.canDecreaseMarginSize
              ? () {
                  ref
                      .read(epubReaderSettingsProvider.notifier)
                      .decreaseMarginSize();
                }
              : null,
        ),
        IconButton(
          icon: FaIcon(FontAwesomeIcons.arrowsLeftRight),
          tooltip: 'Increase Margin Size',
          onPressed: settings.canIncreaseMarginSize
              ? () {
                  ref
                      .read(epubReaderSettingsProvider.notifier)
                      .increaseMarginSize();
                }
              : null,
        ),
        IconButton(
          icon: FaIcon(FontAwesomeIcons.textHeight),
          iconSize: LayoutConstants.smallIcon,
          tooltip: 'Decrease Line Height',
          onPressed: settings.canDecreaseLineHeight
              ? () {
                  ref
                      .read(epubReaderSettingsProvider.notifier)
                      .decreaseLineHeight();
                }
              : null,
        ),
        IconButton(
          icon: FaIcon(FontAwesomeIcons.textHeight),
          tooltip: 'Increase Line Height',
          onPressed: settings.canIncreaseLineHeight
              ? () {
                  ref
                      .read(epubReaderSettingsProvider.notifier)
                      .increaseLineHeight();
                }
              : null,
        ),
        IconButton(
          icon: FaIcon(FontAwesomeIcons.rotateLeft),
          tooltip: 'Reset',
          onPressed: () {
            ref.read(epubReaderSettingsProvider.notifier).reset();
          },
        ),
      ],
    );
  }
}
