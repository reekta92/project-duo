import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../theme/color_tokens.dart';
import '../theme/animations.dart';
import '../constants/app_dimensions.dart';

/// Glass card with frosted blur effect.
class GlassCard extends StatelessWidget {
  final Widget child;
  final Color? tintColor;
  final Color? glowColor; // backward compat
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double? blur;
  final double? opacity;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final bool elevated;

  const GlassCard({
    super.key,
    required this.child,
    this.tintColor,
    this.glowColor,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.blur,
    this.opacity,
    this.onTap,
    this.width,
    this.height,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = tintColor ?? glowColor ?? ColorTokens.glassBg(context, opacity: opacity ?? (elevated ? 0.7 : 0.55));
    final borderClr = ColorTokens.glassBorder(context);
    final b = blur ?? ColorTokens.glassBlur;

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusGlass),
        border: Border.all(color: borderClr, width: 0.5),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusGlass),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: b, sigmaY: b),
          child: Container(
            color: bg,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(AppDimensions.radiusGlass),
                child: Padding(padding: padding, child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ZenButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color? color;
  final bool isFullWidth;
  final bool isLoading;

  const ZenButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.color,
    this.isFullWidth = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final clr = color ?? ColorTokens.primary(context);
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          const SizedBox(
            width: 16,
            height: 16,
            child: ZenLoadingIndicator(),
          )
        else if (icon != null)
          Icon(icon, size: 18),
        if (icon != null || isLoading) const SizedBox(width: 8),
        Text(label),
      ],
    );

    final btn = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: clr,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      child: content,
    );

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: btn);
    }
    return btn;
  }
}

class ZenTextField extends StatelessWidget {
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;

  const ZenTextField({
    super.key,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.controller,
    this.validator,
    this.onChanged,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      onChanged: onChanged,
      keyboardType: keyboardType,
      style: TextStyle(color: ColorTokens.textPrimary(context)),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: ColorTokens.textMuted(context)) : null,
        suffixIcon: suffixIcon,
      ),
    );
  }
}

class ZenProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final Color? color;
  final double? height;

  const ZenProgressBar({
    super.key, 
    required this.progress,
    this.color,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final defaultHeight = height ?? 4.0;
    final primaryColor = color ?? ColorTokens.primary(context);
    final accentColor = color ?? ColorTokens.accent(context);

    return Container(
      height: defaultHeight,
      decoration: BoxDecoration(
        color: ColorTokens.border(context).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(defaultHeight / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(defaultHeight / 2),
            gradient: LinearGradient(
              colors: [
                primaryColor,
                accentColor,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ZenLoadingIndicator extends StatelessWidget {
  const ZenLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      strokeWidth: 2,
      valueColor: AlwaysStoppedAnimation<Color>(ColorTokens.primary(context)),
    );
  }
}

class ZenBottomSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: ColorTokens.glassBg(context, opacity: 0.7),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: ColorTokens.border(context),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Flexible(child: child),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A single settings row with leading icon, title, subtitle & trailing widget.
class SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsRow({
    super.key,
    required this.icon,
    this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final icClr = iconColor ?? ColorTokens.primary(context);
    final iconBg = icClr.withValues(alpha: 0.15);
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: icClr, size: 18),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: ColorTokens.textPrimary(context),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                color: ColorTokens.textSecondary(context),
                fontSize: 12,
              ),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}

/// Section title with optional icon and subtitle.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: ColorTokens.primary(context), size: 18),
          const SizedBox(width: 8),
        ],
        Text(
          title.toUpperCase(),
          style: TextStyle(
            color: ColorTokens.textPrimary(context),
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const Spacer(),
        if (subtitle != null)
          Text(
            subtitle!,
            style: TextStyle(
              color: ColorTokens.textMuted(context),
              fontSize: 13,
            ),
          ),
      ],
    );
  }
}

/// Small coloured badge.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color? color;

  const StatusBadge({
    super.key,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final clr = color ?? ColorTokens.primary(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: clr.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: clr.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: clr,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Shimmer-style loading placeholder.
class LoadingShimmer extends StatefulWidget {
  final double height;
  final double? width;

  const LoadingShimmer({
    super.key,
    this.height = 60,
    this.width,
  });

  @override
  State<LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<LoadingShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) {
        final value = _controller.value;
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * value, 0),
              end: Alignment(1.0 + 2.0 * value, 0),
              colors: isDark
                  ? const [
                      Color(0xFF2A2521),
                      Color(0xFF3A3430),
                      Color(0xFF2A2521),
                    ]
                  : const [
                      Color(0xFFE8E0D4),
                      Color(0xFFF5F0EB),
                      Color(0xFFE8E0D4),
                    ],
            ),
          ),
        );
      },
    );
  }
}

/// Empty state placeholder with icon, text & optional action button.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? buttonLabel;
  final VoidCallback? onButtonPressed;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.buttonLabel,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ZenAnimations.breathingAnimation(
              child: Icon(icon, size: 48, color: ColorTokens.textMuted(context)),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                color: ColorTokens.textPrimary(context),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                color: ColorTokens.textSecondary(context),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            if (buttonLabel != null) ...[
              const SizedBox(height: 20),
              ZenButton(
                label: buttonLabel!,
                onPressed: onButtonPressed,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Thin translucent divider.
class GlassDivider extends StatelessWidget {
  final double thickness;
  final double indent;
  final double endIndent;

  const GlassDivider({
    super.key,
    this.thickness = 0.5,
    this.indent = 16,
    this.endIndent = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
      thickness: thickness,
      indent: indent,
      endIndent: endIndent,
      color: ColorTokens.border(context).withValues(alpha: 0.3),
    );
  }
}

/// Alias for backward compatibility — use GlassCard in new code.
typedef GlowCard = GlassCard;
