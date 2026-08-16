import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Fireworks Showcase';
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
  
  // Grid settings
  static const int gridCrossAxisCount = 2;
  static const double gridChildAspectRatio = 0.75;
  static const double gridCrossAxisSpacing = 12.0;
  static const double gridMainAxisSpacing = 12.0;
}

class AppColors {
  static const Color primary = Color(0xFFFF6B35);
  static const Color secondary = Color(0xFF1E88E5);
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.grey;
  
  // Category colors
  static const Map<String, Color> categoryColors = {
    'Fountain': Color(0xFF4CAF50),
    'Rocket': Color(0xFFFF9800),
    'Ground': Color(0xFF9C27B0),
    'Decorative': Color(0xFFE91E63),
    'Combo': Color(0xFF00BCD4),
  };
}
