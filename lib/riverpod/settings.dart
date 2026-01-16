import 'package:fluvita/riverpod/storage.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/experimental/json_persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hooks_riverpod/experimental/persist.dart';

part 'settings.g.dart';
part 'settings.freezed.dart';

@freezed
sealed class SettingsState with _$SettingsState {
  const factory SettingsState({
    String? url,
    String? apiKey,
  }) = _SettingsState;

  factory SettingsState.fromJson(Map<String, Object?> json) =>
      _$SettingsStateFromJson(json);
}

@riverpod
@JsonPersist()
class Settings extends _$Settings {
  @override
  Future<SettingsState> build() async {
    await persist(ref.watch(storageProvider.future)).future;

    return state.value ?? SettingsState();
  }

  void updateSetting(SettingsState settings) {
    state = AsyncValue.data(settings);
  }
}

@riverpod
String? apiKey(Ref ref) {
  final settings = ref.watch(settingsProvider).value;
  return settings?.apiKey;
}
