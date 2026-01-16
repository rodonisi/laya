import 'package:fluvita/api/models/progress_dto.dart';
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
    required int currentPage,
    String? bookScrollId,
  }) = _ReaderState;

  factory ReaderState.fromJson(Map<String, Object?> json) =>
      _$ReaderStateFromJson(json);
}

@riverpod
class Reader extends _$Reader {
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
      currentPage: progress.pageNum,
      bookScrollId: progress.bookScrollId,
    );
  }

  Future<void> nextPage() async {
    final current = await future;

    if (current.currentPage < current.totalPages) {
      await gotoPage(current.currentPage + 1);
    }
  }

  Future<void> previousPage() async {
    final current = await future;
    if (current.currentPage > 0) {
      await gotoPage(current.currentPage - 1);
    }
  }

  Future<void> gotoPage(int page) async {
    if (state.isLoading) return;
    final current = await future;

    if (page < 0 || page >= current.totalPages) return;

    final readerClient = ref.read(restClientProvider).reader;
    await readerClient.postApiReaderProgress(
      body: ProgressDto(
        libraryId: current.libraryId,
        seriesId: current.series.id,
        volumeId: current.volumeId,
        chapterId: current.chapter.id,
        pageNum: page,
      ),
    );

    if (page >= current.totalPages - 1) {
      await markComplete();
    }

    state = AsyncValue.data(
      current.copyWith(currentPage: page),
    );
  }

  Future<void> reportProgress({int? page, String? scrollId}) async {
    if (state.isLoading) return;
    final current = await future;

    log.d('Reporting progress: page=$page, xpath=$scrollId');

    final readerClient = ref.read(restClientProvider).reader;
    await readerClient.postApiReaderProgress(
      body: ProgressDto(
        libraryId: current.libraryId,
        seriesId: current.series.id,
        volumeId: current.volumeId,
        chapterId: current.chapter.id,
        pageNum: page ?? current.currentPage,
        bookScrollId: scrollId,
      ),
    );
  }

  Future<void> markComplete() async {
    if (state.isLoading) return;
    final current = await future;

    final readerClient = ref.read(restClientProvider).reader;
    await readerClient.postApiReaderProgress(
      body: ProgressDto(
        libraryId: current.libraryId,
        seriesId: current.series.id,
        volumeId: current.volumeId,
        chapterId: current.chapter.id,
        pageNum: current.totalPages,
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
      .unknown;

  return switch (format) {
    .epub => .rightToLeft,
    .cbz => ref.watch(imageReaderSettingsProvider).readDirection,
    .unknown => .rightToLeft,
  };
}
