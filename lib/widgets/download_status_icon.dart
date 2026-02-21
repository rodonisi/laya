import 'package:flutter/material.dart';
import 'package:fluvita/utils/layout_constants.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A small icon overlay that conveys the download state of a chapter, volume,
/// or series.
///
/// - **Downloading** (`isDownloading == true`): shows a `CircularProgressIndicator`.
///   When [progress] is non-null the indicator is determinate (0.0–1.0);
///   otherwise it spins indeterminately.
/// - **Downloaded** (`isDownloaded == true`): shows a static download icon.
/// - **Neither**: renders nothing (`null`-safe; returns `SizedBox.shrink()`).
class DownloadStatusIcon extends StatelessWidget {
  const DownloadStatusIcon({
    super.key,
    required this.isDownloaded,
    required this.isDownloading,
    this.progress,
  });

  /// Whether the content is fully downloaded.
  final bool isDownloaded;

  /// Whether a download is currently in progress.
  final bool isDownloading;

  /// Download progress as a fraction (0.0–1.0), or `null` for indeterminate.
  /// Only meaningful when [isDownloading] is true.
  final double? progress;

  @override
  Widget build(BuildContext context) {
    if (isDownloading) {
      return Card(
        child: Padding(
          padding: LayoutConstants.smallEdgeInsets,
          child: SizedBox.square(
            dimension: 16,
            child: CircularProgressIndicator(value: progress),
          ),
        ),
      );
    }

    if (isDownloaded) {
      return Card(
        child: Padding(
          padding: LayoutConstants.smallEdgeInsets,
          child: Icon(
            LucideIcons.download,
            color: Theme.of(context).colorScheme.tertiary,
            size: 16,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
