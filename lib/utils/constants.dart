import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'SparkShow';
  static const String appVersion = '1.0.0';
  
  // Assets
  static const String productsJsonPath = 'assets/data/products.json';
  
  // Video settings
  static const int maxVideoDurationSeconds = 60;
  
  // UI constants
  static const double cardBorderRadius = 12.0;
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  // Grid settings — 2 columns, slightly taller cards to show thumbnail well
  static const int gridCrossAxisCount = 2;
  static const double gridChildAspectRatio = 0.72;
  static const double gridCrossAxisSpacing = 10.0;
  static const double gridMainAxisSpacing = 10.0;
}

class AppColors {
  static const Color primary    = Color(0xFFFF6B35); // warm orange
  static const Color secondary  = Color(0xFF1E88E5);
  static const Color accent     = Color(0xFFFFB347); // golden

  static const Color background = Color(0xFF0E0E12);
  static const Color surface    = Color(0xFF1A1A24);
  static const Color surfaceAlt = Color(0xFF22222E);

  static const Color textPrimary   = Colors.white;
  static const Color textSecondary = Color(0xFF888899);

  // Category colors — currently one active category; others kept for future
  static const Map<String, Color> categoryColors = {
    'Sky Shooter': Color(0xFFFF6B35), // orange to match app accent
    'Fountain':    Color(0xFF4CAF50),
    'Rocket':      Color(0xFFFF9800),
    'Ground':      Color(0xFF9C27B0),
    'Decorative':  Color(0xFFE91E63),
    'Combo':       Color(0xFF00BCD4),
  };

  // Shot-count badge color
  static const Color shotBadge     = Color(0xFFFFB347);
  static const Color shotBadgeBg   = Color(0x22FFB347);
}
