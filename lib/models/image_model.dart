import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kover/utils/converters/uint8list_converter.dart';

part 'image_model.freezed.dart';
part 'image_model.g.dart';

@freezed
sealed class ImageModel with _$ImageModel {
  const ImageModel._();

  const factory ImageModel({
    @Uint8ListConverter() required Uint8List data,
  }) = _ImageModel;

  factory ImageModel.fromJson(Map<String, Object?> json) =>
      _$ImageModelFromJson(json);
}
