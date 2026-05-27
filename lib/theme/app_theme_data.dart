import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'color_tokens.dart';

class AppThemeData {
  static TextTheme _buildTextTheme(Color textColor) {
    return GoogleFonts.interTextTheme(
      TextTheme(
        displayLarge: TextStyle(color: textColor, fontWeight: FontWeight.w200, fontSize: 32, letterSpacing: -0.5),
        displayMedium: TextStyle(color: textColor, fontWeight: FontWeight.w300, fontSize: 24, letterSpacing: -0.3),
        headlineMedium: TextStyle(color: textColor, fontWeight: FontWeight.w400, fontSize: 20, letterSpacing: -0.2),
        titleMedium: TextStyle(color: textColor, fontWeight: FontWeight.w500, fontSize: 16, letterSpacing: 0),
        bodyLarge: TextStyle(color: textColor, fontWeight: FontWeight.w400, fontSize: 16, letterSpacing: 0.1),
        bodyMedium: TextStyle(color: textColor, fontWeight: FontWeight.w400, fontSize: 14, letterSpacing: 0.1),
        labelLarge: TextStyle(color: textColor, fontWeight: FontWeight.w500, fontSize: 14, letterSpacing: 0.5),
        labelSmall: TextStyle(color: textColor, fontWeight: FontWeight.w400, fontSize: 12, letterSpacing: 0.5),
      ),
    );
  }

  static const _pageTransitionsTheme = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
    },
  );

  static ThemeData get light {
    final textTheme = _buildTextTheme(ColorTokens.lightText);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: ColorTokens.lightBg,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: _pageTransitionsTheme,
      colorScheme: const ColorScheme.light(
        primary: ColorTokens.lightPrimary,
        secondary: ColorTokens.lightSecondary,
        surface: ColorTokens.lightSurface,
        error: ColorTokens.lightError,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: ColorTokens.lightText,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleMedium,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: ColorTokens.lightPrimary,
        unselectedItemColor: ColorTokens.lightTextMuted,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w500),
        unselectedLabelStyle: textTheme.labelSmall,
      ),
      cardTheme: CardThemeData(
        color: ColorTokens.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ColorTokens.glassRadius),
          side: BorderSide(color: ColorTokens.lightBorder.withValues(alpha: 0.3)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        hintStyle: textTheme.bodyMedium?.copyWith(color: ColorTokens.lightTextMuted),
        labelStyle: textTheme.bodyMedium?.copyWith(color: ColorTokens.lightTextSec),
        floatingLabelStyle: textTheme.bodyMedium?.copyWith(color: ColorTokens.lightPrimary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ColorTokens.lightBorder.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ColorTokens.lightBorder.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorTokens.lightPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorTokens.lightError, width: 1.0),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorTokens.lightPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ColorTokens.lightSecondary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ColorTokens.lightCard,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: ColorTokens.lightText),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: ColorTokens.lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: ColorTokens.lightBorder.withValues(alpha: 0.5),
        thickness: 0.5,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return ColorTokens.lightPrimary;
          }
          return ColorTokens.lightTextMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return ColorTokens.lightPrimary.withValues(alpha: 0.3);
          }
          return ColorTokens.lightBorder;
        }),
      ),
    );
  }

  static ThemeData get dark {
    final textTheme = _buildTextTheme(ColorTokens.darkText);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: ColorTokens.darkBg,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: _pageTransitionsTheme,
      colorScheme: const ColorScheme.dark(
        primary: ColorTokens.darkPrimary,
        secondary: ColorTokens.darkSecondary,
        surface: ColorTokens.darkSurface,
        error: ColorTokens.darkError,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: ColorTokens.darkText,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleMedium,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: ColorTokens.darkPrimary,
        unselectedItemColor: ColorTokens.darkTextMuted,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w500),
        unselectedLabelStyle: textTheme.labelSmall,
      ),
      cardTheme: CardThemeData(
        color: ColorTokens.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ColorTokens.glassRadius),
          side: BorderSide(color: ColorTokens.darkBorder.withValues(alpha: 0.3)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        hintStyle: textTheme.bodyMedium?.copyWith(color: ColorTokens.darkTextMuted),
        labelStyle: textTheme.bodyMedium?.copyWith(color: ColorTokens.darkTextSec),
        floatingLabelStyle: textTheme.bodyMedium?.copyWith(color: ColorTokens.darkPrimary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ColorTokens.darkBorder.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ColorTokens.darkBorder.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorTokens.darkPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorTokens.darkError, width: 1.0),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorTokens.darkPrimary,
          foregroundColor: ColorTokens.darkBg,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ColorTokens.darkSecondary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ColorTokens.darkCard,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: ColorTokens.darkText),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: ColorTokens.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: ColorTokens.darkBorder.withValues(alpha: 0.5),
        thickness: 0.5,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return ColorTokens.darkPrimary;
          }
          return ColorTokens.darkTextMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return ColorTokens.darkPrimary.withValues(alpha: 0.3);
          }
          return ColorTokens.darkBorder;
        }),
      ),
    );
  }
}
