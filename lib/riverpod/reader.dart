import 'dart:async';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:fluvita/api/openapi.swagger.dart';
import 'package:fluvita/models/chapter_model.dart';
import 'package:fluvita/models/read_direction.dart';
import 'package:fluvita/models/series_model.dart';
import 'package:fluvita/riverpod/api/book.dart';
import 'package:fluvita/riverpod/api/chapter.dart';
import 'package:fluvita/riverpod/api/client.dart';
import 'package:fluvita/riverpod/api/reader.dart';
import 'package:fluvita/riverpod/api/series.dart';
import 'package:fluvita/riverpod/image_reader_settings.dart';
import 'package:fluvita/utils/logging.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reader.freezed.dart';
part 'reader.g.dart';

@freezed
sealed class ReaderState with _$ReaderState {
  const ReaderState._();

  const factory ReaderState({
    required int libraryId,
    required SeriesModel series,
    required ChapterModel chapter,
    required int volumeId,
    required String title,
    required int totalPages,
    required int initialPage,
    String? bookScrollId,
  }) = _ReaderState;

  factory ReaderState.fromJson(Map<String, Object?> json) =>
      _$ReaderStateFromJson(json);
}

@riverpod
class Reader extends _$Reader {
  Timer? _saveProgressDebounce;

  @override
  Future<ReaderState> build({required int seriesId, int? chapterId}) async {
    final chapter = chapterId != null
        ? await ref.watch(chapterProvider(chapterId: chapterId).future)
        : await ref.watch(continuePointProvider(seriesId: seriesId).future);
    final info = await ref.watch(
      bookInfoProvider(chapterId: chapter.id).future,
    );
    final progress = await ref.watch(
      bookProgressProvider(chapterId: chapter.id).future,
    );
    final series = await ref.watch(
      seriesProvider(seriesId: seriesId).future,
    );

    return ReaderState(
      libraryId: info.libraryId!,
      series: series,
      volumeId: info.volumeId!,
      chapter: chapter,
      title: info.seriesName ?? 'Untitled',
      totalPages: info.pages!,
      initialPage: progress.pageNum,
      bookScrollId: progress.bookScrollId,
    );
  }

  Future<void> saveProgress({required int page, String? scrollId}) async {
    if (state.isLoading) return;
    final current = await future;

    _saveProgressDebounce?.cancel();

    _saveProgressDebounce = Timer(500.ms, () async {
      log.d(
        'Saving progress: page=$page, scrollId=$scrollId, chapter=${current.chapter.id}',
      );

      final client = ref.read(restClientProvider);
      await client.apiReaderProgressPost(
        body: ProgressDto(
          libraryId: current.libraryId,
          seriesId: current.series.id,
          volumeId: current.volumeId,
          chapterId: current.chapter.id,
          pageNum: page.clamp(0, current.totalPages - 1),
          bookScrollId: scrollId,
          lastModifiedUtc: DateTime.now().toUtc(),
        ),
      );

      if (page >= current.totalPages - 1) {
        await markComplete();
      }
    });
  }

  Future<void> markComplete() async {
    if (state.isLoading) return;
    final current = await future;

    final client = ref.read(restClientProvider);
    await client.apiReaderProgressPost(
      body: ProgressDto(
        libraryId: current.libraryId,
        seriesId: current.series.id,
        volumeId: current.volumeId,
        chapterId: current.chapter.id,
        pageNum: current.totalPages,
        lastModifiedUtc: DateTime.now().toUtc(),
      ),
    );
  }
}

@riverpod
ReadDirection readDirection(
  Ref ref, {
  required int seriesId,
  int? chapterId,
}) {
  final format =
      ref.watch(
        readerProvider(seriesId: seriesId, chapterId: chapterId).select(
          (state) => state.value?.series.format,
        ),
      ) ??
      Format.unknown;

  return switch (format) {
    .epub => .rightToLeft,
    .cbz => ref.watch(imageReaderSettingsProvider).readDirection,
    .unknown => .rightToLeft,
  };
}
