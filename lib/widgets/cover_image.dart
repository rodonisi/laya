import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fluvita/riverpod/api/image.dart';
import 'package:fluvita/widgets/async_value.dart';

class SeriesCoverImage extends ConsumerWidget {
  final int seriesId;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const SeriesCoverImage({
    super.key,
    required this.seriesId,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Async(
      asyncValue: ref.watch(seriesCoverProvider(seriesId: seriesId)),
      data: (imageData) => Image.memory(
        imageData,
        fit: fit,
        height: height,
        width: width,
      ),
    );
  }
}

class VolumeCoverImage extends ConsumerWidget {
  final int volumeId;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const VolumeCoverImage({
    super.key,
    required this.volumeId,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Async(
      asyncValue: ref.watch(volumeCoverProvider(volumeId: volumeId)),
      data: (imageData) => ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(8.0),
        child: Image.memory(
          imageData,
          fit: fit,
          height: height,
          width: width,
        ),
      ),
    );
  }
}

class ChapterCoverImage extends ConsumerWidget {
  final int chapterId;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const ChapterCoverImage({
    super.key,
    required this.chapterId,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Async(
      asyncValue: ref.watch(chapterCoverProvider(chapterId: chapterId)),
      data: (imageData) => ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(8.0),
        child: Image.memory(
          imageData,
          fit: fit,
          height: height,
          width: width,
        ),
      ),
    );
  }
}
