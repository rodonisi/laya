import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:laya/riverpod/storage.dart';
import 'package:laya/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/experimental/json_persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_annotation/experimental/persist.dart';

part 'theme.freezed.dart';
part 'theme.g.dart';

final CardThemeData cardThemeData = CardThemeData();

final _lightTheme =
    MaterialTheme(
      Typography.material2021().black,
    ).lightHighContrast().copyWith(
      cardTheme: cardThemeData,
    );

final _darkTheme = MaterialTheme(
  Typography.material2021().white,
).darkMediumContrast();

final _cardTheme = CardThemeData(elevation: 0);

@freezed
sealed class ThemeModel with _$ThemeModel {
  const ThemeModel._();
  const factory ThemeModel({
    @Default(ThemeMode.system) ThemeMode mode,
  }) = _ThemeModel;

  factory ThemeModel.fromJson(Map<String, Object?> json) =>
      _$ThemeModelFromJson(json);

  ThemeData get lightTheme => _lightTheme.copyWith(
    cardTheme: _cardTheme,
  );

  ThemeData get darkTheme => _darkTheme.copyWith(
    cardTheme: _cardTheme,
  );
}

@riverpod
@JsonPersist()
class Theme extends _$Theme {
  @override
  ThemeModel build() {
    persist(ref.watch(storageProvider.future));

    return ThemeModel();
  }

  void setMode(ThemeMode mode) {
    state = ThemeModel(mode: mode);
  }

  void reset() {
    state = ThemeModel(mode: ThemeMode.system);
  }
}
