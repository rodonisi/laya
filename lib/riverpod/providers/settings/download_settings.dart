import 'package:fluvita/riverpod/repository/storage_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/experimental/json_persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hooks_riverpod/experimental/persist.dart';

part 'download_settings.freezed.dart';
part 'download_settings.g.dart';

@freezed
sealed class DownloadSettingsState with _$DownloadSettingsState {
  const factory DownloadSettingsState({
    @Default(3) int concurrentDownloads,
  }) = _DownloadSettingsState;

  factory DownloadSettingsState.fromJson(Map<String, Object?> json) =>
      _$DownloadSettingsStateFromJson(json);
}

@riverpod
@JsonPersist()
class DownloadSettings extends _$DownloadSettings {
  @override
  Future<DownloadSettingsState> build() async {
    await persist(ref.watch(storageProvider.future)).future;
    return state.value ?? const DownloadSettingsState();
  }

  Future<void> setConcurrentDownloads(int count) async {
    final current = await future;
    state = AsyncData(current.copyWith(concurrentDownloads: count));
  }
}
