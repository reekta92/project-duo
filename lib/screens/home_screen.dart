import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_strings.dart';
import '../routes/app_routes.dart';
import '../theme/color_tokens.dart';
import '../theme/theme_provider.dart';
import '../widgets/common_widgets.dart';
import '../widgets/glass_app_bar.dart';
import '../theme/animations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: AppStrings.appTitle,
        automaticallyImplyLeading: false,
        actions: [
          Consumer<ThemeProvider>(
            builder: (_, tp, __) => IconButton(
              icon: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                color: ColorTokens.textMuted(context),
              ),
              onPressed: () => tp.toggleTheme(),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: AppDimensions.paddingPage,
            right: AppDimensions.paddingPage,
            top: AppDimensions.spacingMd,
            bottom: AppDimensions.bottomNavHeight + AppDimensions.spacing2xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ZenAnimations.staggeredEntrance(
                index: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.welcomeBack,
                      style: TextStyle(
                        fontSize: 14,
                        color: ColorTokens.textSecondary(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ready to learn?',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: ColorTokens.textPrimary(context),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              ZenAnimations.staggeredEntrance(
                index: 1,
                child: const SectionHeader(
                  title: 'Dashboard',
                  icon: Icons.dashboard_rounded,
                ),
              ),
              const SizedBox(height: 16),
              
              ZenAnimations.staggeredEntrance(
                index: 2,
                child: _quickStatsRow(context),
              ),
              const SizedBox(height: 32),

              ZenAnimations.staggeredEntrance(
                index: 3,
                child: const SectionHeader(
                  title: 'Daily Challenges',
                  icon: Icons.local_fire_department_rounded,
                ),
              ),
              const SizedBox(height: 16),

              ZenAnimations.staggeredEntrance(
                index: 4,
                child: _buildActionCards(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickStatsRow(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem(context, '0', 'Words', Icons.menu_book_rounded, ColorTokens.primary(context)),
          _statItem(context, '0', 'Streak', Icons.local_fire_department_rounded, ColorTokens.accent(context)),
          _statItem(context, '0%', 'Accuracy', Icons.check_circle_rounded, ColorTokens.success(context)),
        ],
      ),
    );
  }

  Widget _statItem(BuildContext context, String value, String label, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: ColorTokens.textPrimary(context),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: ColorTokens.textSecondary(context),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCards(BuildContext context) {
    return Column(
      children: [
        _ActionCard(
          title: 'Wordle',
          subtitle: 'Guess the hidden word in 6 tries',
          icon: Icons.grid_view_rounded,
          color: ColorTokens.accent(context),
          route: AppRoutes.wordle,
        ),
        const SizedBox(height: 16),
        _ActionCard(
          title: 'Word Chain',
          subtitle: 'Connect words to form a chain',
          icon: Icons.link_rounded,
          color: ColorTokens.primary(context),
          route: AppRoutes.wordChain,
        ),
        const SizedBox(height: 16),
        _ActionCard(
          title: 'Daily Quiz',
          subtitle: 'Test your vocabulary knowledge',
          icon: Icons.quiz_rounded,
          color: ColorTokens.warning(context),
          route: AppRoutes.quiz,
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      onTap: () => Navigator.pushNamed(context, route),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ColorTokens.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: ColorTokens.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: ColorTokens.border(context)),
        ],
      ),
    );
  }
}
