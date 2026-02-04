import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fluvita/riverpod/storage.dart';
import 'package:fluvita/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/experimental/json_persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_annotation/experimental/persist.dart';

part 'theme.freezed.dart';
part 'theme.g.dart';

final CardThemeData cardThemeData = CardThemeData();

class _LabelThumbShape extends RoundSliderThumbShape {
  final _indicatorShape = const DropSliderValueIndicatorShape();

  const _LabelThumbShape();

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    super.paint(
      context,
      center,
      activationAnimation: activationAnimation,
      enableAnimation: enableAnimation,
      sliderTheme: sliderTheme,
      value: value,
      textScaleFactor: textScaleFactor,
      sizeWithOverflow: sizeWithOverflow,
      isDiscrete: isDiscrete,
      labelPainter: labelPainter,
      parentBox: parentBox,
      textDirection: textDirection,
    );
    _indicatorShape.paint(
      context,
      center,
      activationAnimation: const AlwaysStoppedAnimation(1),
      enableAnimation: enableAnimation,
      labelPainter: labelPainter,
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      value: value,
      textScaleFactor: 0.7,
      sizeWithOverflow: sizeWithOverflow,
      isDiscrete: isDiscrete,
      textDirection: textDirection,
    );
  }
}

final _theme = MaterialTheme(
  Typography.material2021().black,
);

final _cardTheme = CardThemeData(elevation: 0);
final _sliderTheme = SliderThemeData(
  showValueIndicator: .never,
  thumbShape: _LabelThumbShape(),
);

@freezed
sealed class ThemeModel with _$ThemeModel {
  const ThemeModel._();
  const factory ThemeModel({
    @Default(ThemeMode.system) ThemeMode mode,
  }) = _ThemeModel;

  factory ThemeModel.fromJson(Map<String, Object?> json) =>
      _$ThemeModelFromJson(json);

  ThemeData get lightTheme =>
      _theme.light().copyWith(cardTheme: _cardTheme, sliderTheme: _sliderTheme);

  ThemeData get darkTheme =>
      _theme.dark().copyWith(cardTheme: _cardTheme, sliderTheme: _sliderTheme);
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
