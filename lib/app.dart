import 'package:flutter/material.dart';
import 'constants/colors.dart';
import 'routes.dart';

class AikidoExamApp extends StatelessWidget {
  const AikidoExamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aikido Exam Trainer',
      theme: ThemeData(
        // Set your primary color
        primaryColor: AppColors.primaryColor,
        // Set the accent color (used in FloatingActionButton, etc.)
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: AppColors.secondaryColor,
        ),
        // Set the background color
        scaffoldBackgroundColor: AppColors.backgroundColor,
        // Set the text color for the entire app
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: AppColors.textColor),  // Previously bodyText1
          bodyMedium: TextStyle(color: AppColors.textColor), // Previously bodyText2
          bodySmall: TextStyle(color: AppColors.textColor),   // For smaller text
        ),
        // Button styles
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonColor,  // Set button color
          ),
        ),
      ),
      initialRoute: '/',
      routes: appRoutes,
    );
  }
}
