import 'package:fluvita/models/read_direction.dart';
import 'package:fluvita/riverpod/repository/storage_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/experimental/persist.dart';
import 'package:riverpod_annotation/experimental/json_persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image_reader_settings.freezed.dart';
part 'image_reader_settings.g.dart';

enum ImageScaleType {
  fitWidth,
  fitHeight,
}

enum ReaderMode {
  horizontal,
  vertical,
}

sealed class ImageReaderSettingsLimits {
  static const double verticalReaderGapMin = 0.0;
  static const double verticalReaderGapMax = 128.0;
  static const double verticalReaderGapStep = 4.0;

  static const double verticalReaderPaddingMin = 0.0;
  static const double verticalReaderPaddingMax = 128.0;
  static const double verticalReaderPaddingStep = 4.0;
}

@freezed
sealed class ImageReaderSettingsState with _$ImageReaderSettingsState {
  const factory ImageReaderSettingsState({
    @Default(ImageScaleType.fitWidth) ImageScaleType scaleType,
    @Default(ReadDirection.leftToRight) ReadDirection readDirection,
    @Default(ReaderMode.horizontal) ReaderMode readerMode,
    @Default(0.0) double verticalReaderGap,
    @Default(0.0) double verticalReaderPadding,
  }) = _ImageReaderSettingsState;

  factory ImageReaderSettingsState.fromJson(Map<String, Object?> json) =>
      _$ImageReaderSettingsStateFromJson(json);
}

@riverpod
@JsonPersist()
class DefaultImageReaderSettings extends _$DefaultImageReaderSettings {
  @override
  ImageReaderSettingsState build() {
    persist(ref.watch(storageProvider.future));
    return const ImageReaderSettingsState();
  }

  void setDefault(ImageReaderSettingsState newDefault) {
    state = newDefault;
  }
}

@riverpod
@JsonPersist()
class ImageReaderSettings extends _$ImageReaderSettings {
  @override
  ImageReaderSettingsState build({required int seriesId}) {
    persist(ref.watch(storageProvider.future));
    return ref.watch(defaultImageReaderSettingsProvider);
  }

  void toggleScaleType() {
    state = state.copyWith(
      scaleType: state.scaleType == .fitWidth ? .fitHeight : .fitWidth,
    );
  }

  void toggleReadDirection() {
    state = state.copyWith(
      readDirection: state.readDirection == .leftToRight
          ? .rightToLeft
          : .leftToRight,
    );
  }

  void toggleReaderMode() {
    state = state.copyWith(
      readerMode: state.readerMode == .horizontal ? .vertical : .horizontal,
    );
  }

  void _setVerticalReaderGap(double gap) {
    state = state.copyWith(
      verticalReaderGap: gap.clamp(
        ImageReaderSettingsLimits.verticalReaderGapMin,
        ImageReaderSettingsLimits.verticalReaderGapMax,
      ),
    );
  }

  void decreaseVerticalReaderGap() {
    _setVerticalReaderGap(
      state.verticalReaderGap - ImageReaderSettingsLimits.verticalReaderGapStep,
    );
  }

  void increaseVerticalReaderGap() {
    _setVerticalReaderGap(
      state.verticalReaderGap + ImageReaderSettingsLimits.verticalReaderGapStep,
    );
  }

  void _setVerticalReaderPadding(double padding) {
    state = state.copyWith(
      verticalReaderPadding: padding.clamp(
        ImageReaderSettingsLimits.verticalReaderPaddingMin,
        ImageReaderSettingsLimits.verticalReaderPaddingMax,
      ),
    );
  }

  void decreaseVerticalReaderPadding() {
    _setVerticalReaderPadding(
      state.verticalReaderPadding -
          ImageReaderSettingsLimits.verticalReaderPaddingStep,
    );
  }

  void increaseVerticalReaderPadding() {
    _setVerticalReaderPadding(
      state.verticalReaderPadding +
          ImageReaderSettingsLimits.verticalReaderPaddingStep,
    );
  }

  void reset() {
    state = ref.read(defaultImageReaderSettingsProvider);
  }

  void setDefault() {
    ref.read(defaultImageReaderSettingsProvider.notifier).setDefault(state);
  }
}
