import 'package:flutter/material.dart';

class AppGradients {
  static const LinearGradient primary = LinearGradient(
    colors: [
      Color(0xFF1976D2),
      Color(0xFF42A5F5),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondary = LinearGradient(
    colors: [
      Color(0xFF43A047),
      Color(0xFF9CCC65),
    ],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );
}
