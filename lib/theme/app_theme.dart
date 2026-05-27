import 'package:flutter/material.dart';
import 'app_theme_data.dart';

/// Convenience extension for quick access to theme tokens.
extension ZenTheme on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
}

class AppTheme {
  static ThemeData get lightTheme => AppThemeData.light;
}
