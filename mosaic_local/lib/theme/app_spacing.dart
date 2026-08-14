import 'package:flutter/material.dart';

/// Spacing, radius, padding, and layout tokens following an 8pt grid system.
abstract final class AppSpacing {
  // Spacing Scale
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double hero = 40.0;

  // Border Radii
  static const double radiusXs = 6.0;
  static const double radiusSm = 10.0;
  static const double radiusMd = 14.0;
  static const double radiusLg = 18.0;
  static const double radiusXl = 22.0;
  static const double radiusXxl = 28.0;
  static const double radiusFull = 999.0;

  // BorderRadius objects
  static const BorderRadius roundedXs = BorderRadius.all(Radius.circular(radiusXs));
  static const BorderRadius roundedSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius roundedMd = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius roundedLg = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius roundedXl = BorderRadius.all(Radius.circular(radiusXl));
  static const BorderRadius roundedXxl = BorderRadius.all(Radius.circular(radiusXxl));
  static const BorderRadius roundedFull = BorderRadius.all(Radius.circular(radiusFull));

  // Common Padding Insets
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 16);
  static const EdgeInsets cardPadding = EdgeInsets.all(18);
  static const EdgeInsets cardPaddingDense = EdgeInsets.all(14);
  static const EdgeInsets modalPadding = EdgeInsets.fromLTRB(20, 24, 20, 24);

  // Box Shadows
  static const List<BoxShadow> subtleShadow = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Color(0x3D000000),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> irisGlowShadow = [
    BoxShadow(
      color: Color(0x336342F5),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> coralGlowShadow = [
    BoxShadow(
      color: Color(0x33FF5537),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> mintGlowShadow = [
    BoxShadow(
      color: Color(0x337AE0B5),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];
}
