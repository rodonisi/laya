import 'package:flutter/material.dart';
import 'package:kover/widgets/settings/option_container.dart';

class ChoiceOption<T> extends StatelessWidget {
  final String title;
  final T value;
  final List<ChoiceOptionEntry<T>> options; // Custom model for labels/icons
  final IconData? icon;
  final void Function(T)? onChanged;

  const ChoiceOption({
    super.key,
    required this.title,
    required this.value,
    required this.options,
    this.icon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return OptionContainer(
      title: title,
      icon: icon,
      child: Row(
        children: [
          Expanded(
            child: SegmentedButton(
              segments: options
                  .map(
                    (option) => ButtonSegment<T>(
                      value: option.value,
                      label: Text(option.label),
                      icon: option.icon != null ? Icon(option.icon) : null,
                    ),
                  )
                  .toList(),
              selected: {value},
              onSelectionChanged: (Set<T> newSelection) {
                if (newSelection.first != value) {
                  onChanged?.call(newSelection.first);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ChoiceOptionEntry<T> {
  final T value;
  final String label;
  final IconData? icon;

  const ChoiceOptionEntry({
    required this.value,
    required this.label,
    this.icon,
  });
}
