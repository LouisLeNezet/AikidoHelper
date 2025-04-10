import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../routes.dart';

class ExamMenuScreen extends StatelessWidget {
  const ExamMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Aikido Exam Helper"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Welcome Text
            const Text(
              "Let's Start Your Exam",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 50),

            // Start Button
            ElevatedButton(
              onPressed: () {
                // Navigate to Countdown Screen
                Navigator.pushNamed(context, AppRoutes.countdown);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50), // Full width
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: AppColors.textColor, // Text color
                backgroundColor: AppColors.buttonColor, // Button color
              ),
              child: const Text(
                "Start Exam",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
