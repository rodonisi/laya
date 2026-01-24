import 'package:flutter_riverpod/experimental/persist.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fluvita/models/read_direction.dart';
import 'package:fluvita/riverpod/storage.dart';
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

@freezed
sealed class ImageReaderSettingsState with _$ImageReaderSettingsState {
  const factory ImageReaderSettingsState({
    required ImageScaleType scaleType,
    required ReadDirection readDirection,
    required ReaderMode readerMode,
    @Default(0.0) double verticalImageGap,
  }) = _ImageReaderSettingsState;

  factory ImageReaderSettingsState.fromJson(Map<String, Object?> json) =>
      _$ImageReaderSettingsStateFromJson(json);
}

@riverpod
@JsonPersist()
class ImageReaderSettings extends _$ImageReaderSettings {
  @override
  ImageReaderSettingsState build() {
    persist(ref.watch(storageProvider.future));

    return ImageReaderSettingsState(
      scaleType: .fitWidth,
      readDirection: .leftToRight,
      readerMode: .horizontal,
    );
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

  void setVerticalImageGap(double gap) {
    state = state.copyWith(
      verticalImageGap: gap.clamp(0.0, 64.0),
    );
  }
}
