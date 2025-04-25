import 'package:flutter/material.dart';
import '../../routes.dart';
import '../../constants/colors.dart';

class ExamSummaryScreen extends StatelessWidget {
  const ExamSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exam Summary Screen')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppRoutes.mainMenu);
          },
          style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: AppColors.textColor,
                backgroundColor: AppColors.buttonColor,
              ),
          child: const Text('Back to Menu'),
        ),
      ),
    );
  }
}
