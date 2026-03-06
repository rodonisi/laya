import 'package:fluvita/models/read_direction.dart';
import 'package:fluvita/riverpod/repository/storage_repository.dart';
import 'package:fluvita/utils/layout_constants.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/experimental/persist.dart';
import 'package:riverpod_annotation/experimental/json_persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'epub_reader_settings.freezed.dart';
part 'epub_reader_settings.g.dart';

@freezed
sealed class EpubReaderSettingsState with _$EpubReaderSettingsState {
  const EpubReaderSettingsState._();
  const factory EpubReaderSettingsState({
    @Default(LayoutConstants.mediumPadding) double marginSize,
    @Default(14.0) double fontSize,
    @Default(1.5) double lineHeight,
    @Default(ReadDirection.leftToRight) ReadDirection readDirection,
  }) = _EpubReaderSettingsState;

  factory EpubReaderSettingsState.fromJson(Map<String, Object?> json) =>
      _$EpubReaderSettingsStateFromJson(json);

  static const double minFontSize = 8.0;
  static const double maxFontSize = 24.0;
  static const double minMarginSize = LayoutConstants.smallerPadding;
  static const double maxMarginSize = LayoutConstants.largerPadding;
  static const double minLineHeight = 0.5;
  static const double maxLineHeight = 3.0;

  bool get canIncreaseFontSize => fontSize < maxFontSize;
  bool get canDecreaseFontSize => fontSize > minFontSize;
  bool get canIncreaseMarginSize => marginSize < maxMarginSize;
  bool get canDecreaseMarginSize => marginSize > minMarginSize;
  bool get canIncreaseLineHeight => lineHeight < maxLineHeight;
  bool get canDecreaseLineHeight => lineHeight > minLineHeight;
}

@riverpod
@JsonPersist()
class DefaultEpubReaderSettings extends _$DefaultEpubReaderSettings {
  @override
  EpubReaderSettingsState build() {
    persist(ref.watch(storageProvider.future));
    return const EpubReaderSettingsState();
  }

  void setDefault(EpubReaderSettingsState newDefault) {
    state = newDefault;
  }
}

@riverpod
@JsonPersist()
class EpubReaderSettings extends _$EpubReaderSettings {
  @override
  EpubReaderSettingsState build({required int seriesId}) {
    persist(ref.watch(storageProvider.future));
    return ref.watch(defaultEpubReaderSettingsProvider);
  }

  void toggleReadDirection() {
    state = state.copyWith(
      readDirection: state.readDirection == ReadDirection.leftToRight
          ? ReadDirection.rightToLeft
          : ReadDirection.leftToRight,
    );
  }

  void increaseFontSize() {
    if (state.fontSize >= EpubReaderSettingsState.maxFontSize) {
      return;
    }
    state = state.copyWith(fontSize: state.fontSize + 1);
  }

  void decreaseFontSize() {
    if (state.fontSize <= EpubReaderSettingsState.minFontSize) {
      return;
    }

    state = state.copyWith(fontSize: state.fontSize - 1);
  }

  void increaseMarginSize() {
    if (state.marginSize >= EpubReaderSettingsState.maxMarginSize) {
      return;
    }

    state = state.copyWith(marginSize: state.marginSize + 4);
  }

  void decreaseMarginSize() {
    if (state.marginSize <= EpubReaderSettingsState.minMarginSize) {
      return;
    }

    state = state.copyWith(marginSize: state.marginSize - 4);
  }

  void increaseLineHeight() {
    if (state.lineHeight >= EpubReaderSettingsState.maxLineHeight) {
      return;
    }

    state = state.copyWith(lineHeight: state.lineHeight + 0.2);
  }

  void decreaseLineHeight() {
    if (state.lineHeight <= EpubReaderSettingsState.minLineHeight) {
      return;
    }

    state = state.copyWith(lineHeight: state.lineHeight - 0.2);
  }

  void reset() {
    state = ref.read(defaultEpubReaderSettingsProvider);
  }

  void setDefault() {
    ref.read(defaultEpubReaderSettingsProvider.notifier).setDefault(state);
  }
}
