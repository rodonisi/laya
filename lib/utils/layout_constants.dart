import 'package:flutter/rendering.dart';

sealed class LayoutConstants {
  static const double smallerPadding = 4.0;
  static const double smallPadding = 8.0;
  static const double mediumPadding = 16.0;
  static const double largePadding = 32.0;
  static const double largerPadding = 64.0;

  static const EdgeInsets smallerEdgeInsets = EdgeInsets.all(smallerPadding);
  static const EdgeInsets smallEdgeInsets = EdgeInsets.all(smallPadding);
  static const EdgeInsets mediumEdgeInsets = EdgeInsets.all(mediumPadding);
  static const EdgeInsets largeEdgeInsets = EdgeInsets.all(largePadding);
  static const EdgeInsets largerEdgeInsets = EdgeInsets.all(largerPadding);
}
