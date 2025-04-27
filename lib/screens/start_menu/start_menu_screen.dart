import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../routes.dart';

class StartMenuScreen extends StatelessWidget {
  const StartMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.mainMenu),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32.0),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.headerColor, AppColors.accentColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              SizedBox(
                width: double.infinity,
                child: Image.asset(
                  'assets/images/logo.jpg', // Correct asset path
                  height: 160,
                  fit: BoxFit.contain, // Make sure it scales properly
                ),
              ),
              const SizedBox(height: 32),

              // App Name
              const Text(
                'Aïkido Exam Trainer',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 16),
              const Text(
                'Tap anywhere to start',
                style: TextStyle(color: AppColors.accentColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
