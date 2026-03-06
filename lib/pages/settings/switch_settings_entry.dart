import 'package:flutter/material.dart';

class SwitchSettingsEntry extends StatelessWidget {
  final String title;
  final bool value;
  final void Function(bool) onChanged;

  const SwitchSettingsEntry({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const Spacer(),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}
