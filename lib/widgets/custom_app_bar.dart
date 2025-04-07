import 'package:flutter/material.dart';
import '../constants/colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(120.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 120.0,
      backgroundColor: AppColors.headerColor,
      automaticallyImplyLeading: false, // No back button
      flexibleSpace: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // App Logo
          Image.asset(
            'assets/images/logo.jpg', // Your logo
            height: 50,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 8),
          // App Name
          const Text(
            'Aïkido Exam Trainer',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
