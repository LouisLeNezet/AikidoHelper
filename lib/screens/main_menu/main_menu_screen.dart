import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import '../../constants/colors.dart';
import '../../routes.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Start Exam Button
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.examMenu);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50), // Full width
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: AppColors.textColor, // Text color
                backgroundColor: AppColors.buttonColor, // Button color
              ),
              child: const Text(
                'Start Exam',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            
            // Train Button
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.trainMenu);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: AppColors.textColor,
                backgroundColor: AppColors.buttonColor,
              ),
              child: const Text(
                'Train',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            
            // Progression Button
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.progressionList);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: AppColors.textColor,
                backgroundColor: AppColors.buttonColor,
              ),
              child: const Text(
                'Progression',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            
            // Configure Button
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.config);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: AppColors.textColor,
                backgroundColor: AppColors.buttonColor,
              ),
              child: const Text(
                'Configure',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            
            // More Info Button
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.moreInfos);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: AppColors.textColor,
                backgroundColor: AppColors.buttonColor,
              ),
              child: const Text(
                'More Info',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
