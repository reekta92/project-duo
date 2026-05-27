import 'package:flutter/material.dart';

/// Warm-neutral palette for zen design
abstract class ColorTokens {
  // ── Light ─────────────────────────────────────────────────────────
  static const lightBg = Color(0xFFF7F5F0); // warm ivory
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceElevated = Color(0xFFF0EBE1);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightText = Color(0xFF2D2D2D); // near-black
  static const lightTextSec = Color(0xFF6B6B6B); // warm grey
  static const lightTextMuted = Color(0xFFA0A0A0);
  static const lightBorder = Color(0xFFE0DDD8);
  static const lightPrimary = Color(0xFF6B7C6E); // sage green
  static const lightSecondary = Color(0xFFB8A99A); // warm stone
  static const lightAccent = Color(0xFFC4907C); // dusty rose
  static const lightError = Color(0xFFC47070); // muted red
  static const lightSuccess = Color(0xFF7BA37E); // muted green
  static const lightWarning = Color(0xFFE3A05B); // warm amber
  static const lightGlassBg = Color(0xFFFFFFFF); // card base

  // Gradients for light mode mesh background
  static const lightGrad1 = Color(0xFFF0EBE1);
  static const lightGrad2 = Color(0xFFE6E0D3);
  
  // Shimmer for light mode
  static const lightShimmerBase = Color(0xFFE8E0D4);
  static const lightShimmerHighlight = Color(0xFFF5F0EB);

  // ── Dark ──────────────────────────────────────────────────────────
  static const darkBg = Color(0xFF1A1A1E); // deep charcoal
  static const darkSurface = Color(0xFF2A2A2E);
  static const darkSurfaceElevated = Color(0xFF35353A);
  static const darkCard = Color(0xFF2A2A2E);
  static const darkText = Color(0xFFE8E4DF); // warm white
  static const darkTextSec = Color(0xFFA0A0A0); // mid grey
  static const darkTextMuted = Color(0xFF6B6B6B);
  static const darkBorder = Color(0xFF404040);
  static const darkPrimary = Color(0xFF8FA393); // lighter sage
  static const darkSecondary = Color(0xFFC4B5A6); // lighter stone
  static const darkAccent = Color(0xFFD4A090); // lighter rose
  static const darkError = Color(0xFFD48585);
  static const darkSuccess = Color(0xFF8FB892);
  static const darkWarning = Color(0xFFE5B57B); // lighter amber
  static const darkGlassBg = Color(0xFF2A2A2E);

  // Gradients for dark mode mesh background
  static const darkGrad1 = Color(0xFF202025);
  static const darkGrad2 = Color(0xFF151518);

  // Shimmer for dark mode
  static const darkShimmerBase = Color(0xFF2A2521);
  static const darkShimmerHighlight = Color(0xFF3A3430);

  // ── Glass helpers ─────────────────────────────────────────────────
  static Color glassBg(BuildContext context, {double opacity = 0.55}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? darkGlassBg : lightGlassBg;
    return base.withValues(alpha: opacity);
  }

  static Color glassBorder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return (isDark ? darkBorder : lightBorder).withValues(alpha: 0.3); // 0.3 alpha for borders
  }

  static double get glassBlur => 20.0; // Increased blur for softer effect
  static double get glassRadiusSm => 12.0;
  static double get glassRadius => 20.0; // md
  static double get glassRadiusLg => 28.0;

  // ── Themed accessors ──────────────────────────────────────────────
  static Color primary(BuildContext context) =>
      _c(context, lightPrimary, darkPrimary);
  static Color secondary(BuildContext context) =>
      _c(context, lightSecondary, darkSecondary);
  static Color accent(BuildContext context) =>
      _c(context, lightAccent, darkAccent);
  static Color error(BuildContext context) =>
      _c(context, lightError, darkError);
  static Color success(BuildContext context) =>
      _c(context, lightSuccess, darkSuccess);
  static Color warning(BuildContext context) =>
      _c(context, lightWarning, darkWarning);
  static Color surface(BuildContext context) =>
      _c(context, lightSurface, darkSurface);
  static Color surfaceElevated(BuildContext context) =>
      _c(context, lightSurfaceElevated, darkSurfaceElevated);
  static Color textPrimary(BuildContext context) =>
      _c(context, lightText, darkText);
  static Color textSecondary(BuildContext context) =>
      _c(context, lightTextSec, darkTextSec);
  static Color textMuted(BuildContext context) =>
      _c(context, lightTextMuted, darkTextMuted);
  static Color border(BuildContext context) =>
      _c(context, lightBorder, darkBorder);

  static Color _c(BuildContext context, Color light, Color dark) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}
