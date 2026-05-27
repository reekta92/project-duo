import 'package:flutter/material.dart';
import '../theme/color_tokens.dart';

class ZenBackground extends StatelessWidget {
  const ZenBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color1 = isDark ? ColorTokens.darkGrad1 : ColorTokens.lightGrad1;
    final color2 = isDark ? ColorTokens.darkGrad2 : ColorTokens.lightGrad2;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? ColorTokens.darkBg : ColorTokens.lightBg,
      ),
      child: Stack(
        children: [
          // Top right subtle blob
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    color1.withValues(alpha: 0.8),
                    color1.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          // Bottom left subtle blob
          Positioned(
            bottom: -150,
            left: -50,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    color2.withValues(alpha: 0.6),
                    color2.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          // Center subtle blob
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    (isDark ? ColorTokens.darkPrimary : ColorTokens.lightPrimary)
                        .withValues(alpha: 0.05),
                    (isDark ? ColorTokens.darkPrimary : ColorTokens.lightPrimary)
                        .withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
