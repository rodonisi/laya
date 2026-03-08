import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kover/models/image_model.dart';
import 'package:kover/riverpod/providers/chapter.dart';
import 'package:kover/riverpod/providers/series.dart';
import 'package:kover/riverpod/providers/volume.dart';
import 'package:kover/widgets/async_value.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
      data: (imageData) => PlaceholderCoverImage(
        image: imageData,
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
        child: PlaceholderCoverImage(
          image: imageData,
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
        child: PlaceholderCoverImage(
          image: imageData,
          fit: fit,
          height: height,
          width: width,
        ),
      ),
    );
  }
}

class PlaceholderCoverImage extends StatelessWidget {
  final ImageModel? image;
  final double? width;
  final double? height;
  final BoxFit fit;
  const PlaceholderCoverImage({
    super.key,
    this.image,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (image == null) {
      return const Center(child: Icon(LucideIcons.image));
    }

    return Image.memory(
      image!.data,
      fit: fit,
      height: height,
      width: width,
    );
  }
}
