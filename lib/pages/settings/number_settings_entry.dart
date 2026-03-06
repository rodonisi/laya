import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluvita/utils/layout_constants.dart';

class NumberSettingsEntry extends HookWidget {
  final String title;
  final int value;
  final void Function(int) onChanged;
  final int min;
  final int max;

  const NumberSettingsEntry({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    required this.min,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .start,
      spacing: LayoutConstants.smallerPadding,
      children: [
        Text(title, style: textTheme.titleMedium),
        Row(
          spacing: LayoutConstants.mediumPadding,
          children: [
            Expanded(
              child: Slider(
                min: min.toDouble(),
                max: max.toDouble(),
                divisions: max - min,
                value: value.toDouble(),
                onChanged: (value) {
                  onChanged(value.toInt());
                },
                padding: .zero,
              ),
            ),
            Text(
              value.toString(),
            ),
          ],
        ),
      ],
    );
  }
}
