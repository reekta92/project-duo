import 'package:flutter/material.dart';
import '../constants/constants.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.wordGame)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.gamepad,
              size: AppDimensions.iconLg,
              color: AppColors.green,
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            const Text(
              AppStrings.gameComingSoon,
              style: TextStyle(
                fontSize: AppDimensions.fontSubheading,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            const Text(AppStrings.gameDesc),
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
