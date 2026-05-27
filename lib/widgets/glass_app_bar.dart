import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../theme/color_tokens.dart';
import '../constants/app_dimensions.dart';

/// Frosted glass AppBar with blur effect.
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final double blur;
  final double opacity;
  final bool scrolledUnder; // If true, apply blur
  final PreferredSizeWidget? bottom;

  const GlassAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.blur = 20.0,
    this.opacity = 0.55,
    this.scrolledUnder = true,
    this.bottom,
  });

  @override
  Size get preferredSize {
    double height = AppDimensions.appBarCompactHeight;
    if (bottom != null) {
      height += bottom!.preferredSize.height;
    }
    return Size.fromHeight(height);
  }

  @override
  Widget build(BuildContext context) {
    final borderClr = ColorTokens.border(context).withValues(alpha: scrolledUnder ? 0.2 : 0.0);
    final bg = ColorTokens.glassBg(context, opacity: scrolledUnder ? opacity : 0.0);

    return SizedBox(
      height: preferredSize.height + MediaQuery.of(context).padding.top,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(
            sigmaX: scrolledUnder ? blur : 0.0, 
            sigmaY: scrolledUnder ? blur : 0.0
          ),
          child: Container(
            decoration: BoxDecoration(
              color: bg,
              border: Border(bottom: BorderSide(color: borderClr)),
            ),
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: AppBar(
              title: titleWidget ?? (title != null ? Text(title!) : null),
              actions: actions,
              leading: leading,
              automaticallyImplyLeading: automaticallyImplyLeading,
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              foregroundColor: ColorTokens.textPrimary(context),
              bottom: bottom,
            ),
          ),
        ),
      ),
    );
  }
}
