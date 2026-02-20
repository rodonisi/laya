import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:fluvita/utils/layout_constants.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CoverCard extends StatelessWidget {
  final String? title;
  final Icon? icon;
  final String actionLabel;
  final Icon actionIcon;
  final double progress;
  final Widget coverImage;
  final Widget? downloadStatusIcon;
  final void Function()? onTap;
  final void Function()? onRead;

  const CoverCard({
    super.key,
    this.title,
    this.icon,
    this.actionLabel = 'Read',
    this.actionIcon = const Icon(LucideIcons.bookOpen),
    required this.coverImage,
    this.downloadStatusIcon,
    this.onTap,
    this.onRead,
    double? progress,
  }) : progress = progress ?? 0.0;

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      clipBehavior: .antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: coverImage,
                  ),
                  if (progress <= 0)
                    Align(
                      alignment: .topRight,
                      child: Transform.translate(
                        offset: const Offset(20, -20),
                        child: Transform.rotate(
                          angle: math.pi / 4,
                          child: Container(
                            width: 40,
                            height: 40,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  if (onRead != null)
                    Align(
                      alignment: .bottomCenter,
                      child: Padding(
                        padding: LayoutConstants.smallEdgeInsets,
                        child: FilledButton.icon(
                          icon: actionIcon,
                          label: FittedBox(child: Text(actionLabel)),
                          onPressed: onRead,
                        ),
                      ),
                    ),
                  if (downloadStatusIcon != null)
                    Align(
                      alignment: .topLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: downloadStatusIcon,
                      ),
                    ),
                ],
              ),
            ),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
            ),
            if (title != null)
              Padding(
                padding: LayoutConstants.smallEdgeInsets,
                child: Row(
                  mainAxisSize: .min,
                  spacing: LayoutConstants.smallPadding,
                  children: [
                    ?icon,
                    Expanded(
                      child: Text(
                        title!,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
