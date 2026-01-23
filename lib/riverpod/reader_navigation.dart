import 'dart:async';

import 'package:fluvita/riverpod/reader.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reader_navigation.freezed.dart';
part 'reader_navigation.g.dart';

@freezed
sealed class ReaderNavigationState with _$ReaderNavigationState {
  const factory ReaderNavigationState({
    required int currentPage,
    @Default(0.0) double scrollOffset,
    @Default(0) int visibleStart,
    @Default(0) int visibleEnd,
  }) = _ReaderNavigationState;
}

@riverpod
class ReaderNavigation extends _$ReaderNavigation {
  Timer? _saveTimer;

  @override
  ReaderNavigationState build({
    required int seriesId,
    required int chapterId,
  }) {
    // Initialize from reader state's last saved page
    final readerState = ref.watch(
      readerProvider(seriesId: seriesId, chapterId: chapterId),
    );
    final initialPage = readerState.value?.currentPage ?? 0;

    return ReaderNavigationState(
      currentPage: initialPage,
    );
  }

  void setPage(int page) {
    state = state.copyWith(currentPage: page);

    // Debounced save to server
    _scheduleSave(page);
  }

  void _scheduleSave(int page) {
    _saveTimer?.cancel();
    _saveTimer = Timer(Duration(seconds: 2), () {
      ref.read(
        readerProvider(seriesId: seriesId, chapterId: chapterId).notifier,
      ).saveProgress(page: page);
    });
  }

  void updateScrollPosition({
    required double offset,
    required int visibleStart,
    required int visibleEnd,
  }) {
    state = state.copyWith(
      scrollOffset: offset,
      visibleStart: visibleStart,
      visibleEnd: visibleEnd,
    );
  }

  void nextPage() => setPage(state.currentPage + 1);
  void previousPage() => setPage(state.currentPage - 1);
  void jumpToPage(int page) => setPage(page);
}
