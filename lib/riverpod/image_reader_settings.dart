import 'package:flutter_riverpod/experimental/persist.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:laya/riverpod/storage.dart';
import 'package:riverpod_annotation/experimental/json_persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image_reader_settings.g.dart';
part 'image_reader_settings.freezed.dart';

enum ImageScaleType {
  fitWidth,
  fitHeight,
}

enum ReadDirection {
  leftToRight,
  rightToLeft,
}

enum ReaderMode {
  horizontal,
  vertical,
}

@freezed
sealed class ImageReaderSettingsState with _$ImageReaderSettingsState {
  const ImageReaderSettingsState._();

  const factory ImageReaderSettingsState({
    required ImageScaleType scaleType,
    required ReadDirection readDirection,
    required ReaderMode readerMode,
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
      scaleType: ImageScaleType.fitWidth,
      readDirection: ReadDirection.leftToRight,
      readerMode: ReaderMode.horizontal,
    );
  }

  void toggleScaleType() {
    state = state.copyWith(
      scaleType: state.scaleType == ImageScaleType.fitWidth
          ? ImageScaleType.fitHeight
          : ImageScaleType.fitWidth,
    );
  }

  void toggleReadDirection() {
    state = state.copyWith(
      readDirection: state.readDirection == ReadDirection.leftToRight
          ? ReadDirection.rightToLeft
          : ReadDirection.leftToRight,
    );
  }

  void toggleReaderMode() {
    state = state.copyWith(
      readerMode: state.readerMode == ReaderMode.horizontal
          ? ReaderMode.vertical
          : ReaderMode.horizontal,
    );
  }
}
