import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:laya/riverpod/api/reader.dart';
import 'package:laya/riverpod/image_reader_settings.dart';
import 'package:laya/widgets/async_value.dart';

class ImageReader extends ConsumerWidget {
  final int chapterId;
  final int page;
  final int totalPages;

  const ImageReader({
    super.key,
    required this.chapterId,
    required this.page,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(imageReaderSettingsProvider);

    return Async(
      asyncValue: ref.watch(
        readerImageProvider(chapterId: chapterId, page: page),
      ),
      data: (data) {
        return Image.memory(
          data,
          fit: settings.scaleType == .fitWidth ? .fitWidth : .fitHeight,
        );
      },
    );
  }
}
