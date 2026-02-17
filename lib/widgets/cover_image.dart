import 'package:flutter/material.dart';
import 'package:fluvita/riverpod/api/chapter.dart';
import 'package:fluvita/riverpod/api/series.dart';
import 'package:fluvita/riverpod/api/volume.dart';
import 'package:fluvita/widgets/async_value.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
        imageData.data,
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
        child: Image.memory(
          imageData.data,
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
        child: Image.memory(
          imageData.data,
          fit: fit,
          height: height,
          width: width,
        ),
      ),
    );
  }
}
