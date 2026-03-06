import 'package:flutter/material.dart';
import 'package:fluvita/utils/layout_constants.dart';

class ChoiceSettingsEntry<T> extends StatelessWidget {
  final String title;
  final List<ButtonSegment<T>> segments;
  final T selected;
  final void Function(T) onSelectionChanged;

  const ChoiceSettingsEntry({
    super.key,
    required this.title,
    required this.segments,
    required this.selected,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .start,
      spacing: LayoutConstants.smallerPadding,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        Center(
          child: SizedBox(
            width: double.infinity,
            child: SegmentedButton<T>(
              segments: segments,
              selected: {selected},
              onSelectionChanged: (Set<T> newSelection) {
                onSelectionChanged(newSelection.first);
              },
            ),
          ),
        ),
      ],
    );
  }
}
