import 'package:fluvita/riverpod/reader.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reader_navigation.freezed.dart';
part 'reader_navigation.g.dart';

@freezed
sealed class ReaderNavigationState with _$ReaderNavigationState {
  const factory ReaderNavigationState({
    required int currentPage,
    required int totalPages,
  }) = _ReaderNavigationState;
}

@riverpod
class ReaderNavigation extends _$ReaderNavigation {
  @override
  ReaderNavigationState build({
    required int seriesId,
    required int chapterId,
  }) {
    // Initialize from reader state's last saved page
    final readerState = ref.watch(
      readerProvider(seriesId: seriesId, chapterId: chapterId),
    );

    return ReaderNavigationState(
      currentPage: readerState.value?.initialPage ?? 0,
      totalPages: readerState.value?.totalPages ?? 0,
    );
  }

  void jumpToPage(int page) {
    state = state.copyWith(
      currentPage: page.clamp(0, state.totalPages-1),
    );

    ref
        .read(
          readerProvider(
            seriesId: seriesId,
            chapterId: chapterId,
          ).notifier,
        )
        .saveProgress(page: page);
  }

  void nextPage() => jumpToPage(state.currentPage + 1);
  void previousPage() => jumpToPage(state.currentPage - 1);
}
