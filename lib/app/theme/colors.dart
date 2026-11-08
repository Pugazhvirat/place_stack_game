import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color backgroundTop = Color(0xFF030A24);
  static const Color backgroundBottom = Color(0xFF081C4D);
  static const Color surface = Color(0xFF0B1A3F);
  static const Color dialogBackground = Color(0xFF000000);
  static const Color dialogCardBackground = Color(0xFF343B48);

  static const Color surfaceLight = Color(0xFF13296B);
  static const Color border = Color(0xFF1B4FD6);
  static const Color neonBlue = Color(0xFF1E8CFF);
  static const Color blueDark = Color(0xFF0B4FD0);
  static const Color cyan = Color(0xFF19E6FF);
  static const Color green = Color(0xFF1FD66B);
  static const Color greenDark = Color(0xFF0FA64E);
  static const Color purple = Color(0xFF8A3DFF);
  static const Color purpleDark = Color(0xFF5B1FD1);
  static const Color gold = Color(0xFFFFC62E);
  static const Color goldDark = Color(0xFFE08A00);
  static const Color pink = Color(0xFFFF4FA3);
  static const Color orange = Color(0xFFFF9A4D);
  static const Color red = Color(0xFFFF3B5C);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFA9B8E0);

  /// Bottom-to-top rainbow used by the default skin.
  static const List<Color> defaultBlockPalette = <Color>[
    Color(0xFF1FD67A),
    Color(0xFF12D3B5),
    Color(0xFF19C8FF),
    Color(0xFF1E7BFF),
    Color(0xFF8F4DFF),
    Color(0xFFFF4FA3),
    Color(0xFFFF9A4D),
    Color(0xFFFFD84A),
  ];

  /// One of these is used for the whole run; a new one is picked every new game.
  static const List<Color> runColors = <Color>[
    Color(0xFF1FD67A), // green
    Color(0xFF19C8FF), // cyan
    Color(0xFF1E7BFF), // blue
    Color(0xFF8F4DFF), // purple
    Color(0xFFFF4FA3), // pink
    Color(0xFFFF9A4D), // orange
    // Color(0xFFFFD84A), // yellow
    Color(0xFFFF3B5C), // red
    Color(0xFF12D3B5), // teal
    // Color(0xFFB14DFF), // violet2
  ];
}
