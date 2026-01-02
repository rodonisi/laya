import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:laya/riverpod/storage.dart';
import 'package:laya/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/experimental/json_persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_annotation/experimental/persist.dart';

part 'theme.freezed.dart';
part 'theme.g.dart';

final _lightTheme = MaterialTheme(
  Typography.material2021().black,
).lightHighContrast();
final _darkTheme = MaterialTheme(
  Typography.material2021().white,
).darkMediumContrast();

@freezed
sealed class ThemeModel with _$ThemeModel {
  const ThemeModel._();
  const factory ThemeModel({
    @Default(ThemeMode.system) ThemeMode mode,
  }) = _ThemeModel;

  factory ThemeModel.fromJson(Map<String, Object?> json) =>
      _$ThemeModelFromJson(json);

  ThemeData get lightTheme => _lightTheme;
  ThemeData get darkTheme => _darkTheme;
}

@riverpod
@JsonPersist()
class Theme extends _$Theme {
  @override
  Future<ThemeModel> build() async {
    await persist(ref.watch(storageProvider.future)).future;

    return state.value ?? ThemeModel();
  }

  void setMode(ThemeMode mode) {
    state = AsyncData(ThemeModel(mode: mode));
  }

  void reset() {
    state = AsyncData(ThemeModel(mode: ThemeMode.system));
  }
}
