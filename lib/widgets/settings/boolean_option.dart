import 'package:flutter/material.dart';
import 'package:kover/widgets/settings/option_container.dart';

class BooleanOption extends StatelessWidget {
  final String title;
  final bool value;
  final IconData? icon;
  final void Function(bool)? onChanged;
  const BooleanOption({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return OptionContainer(
      title: title,
      icon: icon,
      sameRow: true,
      child: Row(
        mainAxisAlignment: .end,
        children: [
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
