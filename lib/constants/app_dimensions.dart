import 'package:flutter/material.dart';

abstract class AppDimensions {
  // ── Responsive helpers ────────────────────────────────────────────
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 900;
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 900;

  static double responsive(BuildContext context,
      {double mobile = 1.0, double tablet = 1.25, double? desktop}) {
    final d = desktop ?? tablet;
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return d;
  }

  static double scale(BuildContext context, double base) =>
      base * responsive(context, mobile: 1.0, tablet: 1.1, desktop: 1.2);

  // ── Bottom Nav ────────────────────────────────────────────────────
  static const bottomNavHeight = 64.0;
  static const bottomNavPaddingBottom = 8.0;

  // ── App Bar ───────────────────────────────────────────────────────
  static const appBarCompactHeight = 48.0;

  // ── Icons ─────────────────────────────────────────────────────────
  static const iconXl = 64.0;
  static const iconLg = 48.0;
  static const iconMd = 32.0;
  static const iconMenu = 24.0;
  static const iconSm = 20.0;

  // ── Spacing ───────────────────────────────────────────────────────
  static const spacingXs = 4.0;
  static const spacingSm = 8.0;
  static const spacingMd = 16.0;
  static const spacingLg = 20.0;
  static const spacingXl = 24.0;
  static const spacing2xl = 28.0;
  static const spacing3xl = 36.0;

  static const paddingPage = 16.0;
  static const paddingCard = 16.0;
  static const paddingForm = 24.0;
  static const paddingInner = 16.0;

  // ── Radius ────────────────────────────────────────────────────────
  static const radiusSm = 10.0;
  static const radiusMd = 12.0;
  static const radiusLg = 14.0;
  static const radiusXl = 20.0;
  static const radiusGlass = 20.0;

  // ── Buttons ───────────────────────────────────────────────────────
  static const buttonHeight = 50.0;
  static const buttonHeightSm = 44.0;
  static const buttonHeightXs = 38.0;

  // ── Elevation (minimal — zen) ─────────────────────────────────────
  static const elevationNone = 0.0;
  static const elevationSoft = 1.0;
  static const elevationCard = 0.0;
  static const elevationCardHigh = 0.0;
  static const elevationButton = 0.0;
  static const elevationButtonHigh = 0.0;
}
