import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../routes/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.mainMenu),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingPage),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.school,
              size: AppDimensions.iconXl,
              color: AppColors.seed,
            ),
            const SizedBox(height: AppDimensions.spacing2xl),
            const Text(
              AppStrings.welcome,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppDimensions.fontHeading,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            const Text(
              AppStrings.whichModule,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppDimensions.fontSubtitle,
                color: AppColors.grey,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing3xl),
            _buildMenuButton(
              context,
              AppStrings.startGame,
              Icons.play_arrow,
              AppColors.green,
              AppRoutes.game,
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            _buildMenuButton(
              context,
              AppStrings.myProgress,
              Icons.trending_up,
              AppColors.orange,
              AppRoutes.progress,
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            _buildMenuButton(
              context,
              AppStrings.settings,
              Icons.settings,
              AppColors.blue,
              AppRoutes.settings,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String route,
  ) {
    return ElevatedButton.icon(
      onPressed: () => Navigator.pushNamed(context, route),
      icon: Icon(icon, size: AppDimensions.iconMenu),
      label: Text(
        title,
        style: const TextStyle(fontSize: AppDimensions.fontBody),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spacingMd - 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        elevation: AppDimensions.elevationButtonHigh,
      ),
    );
  }
}
