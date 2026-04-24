import 'package:flutter/material.dart';
import '../constants/constants.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.myProgress)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.trending_up,
              size: AppDimensions.iconLg,
              color: AppColors.orange,
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            const Text(
              AppStrings.statsComingSoon,
              style: TextStyle(
                fontSize: AppDimensions.fontSubheading,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            const Text(AppStrings.statsDesc),
            const SizedBox(height: AppDimensions.spacing2xl),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(AppStrings.backToMenu),
            ),
          ],
        ),
      ),
    );
  }
}
