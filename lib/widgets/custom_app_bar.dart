import 'package:flutter/material.dart';
import '../constants/colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(60.0); // Reduced height

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 60.0, // Reduced height
      backgroundColor: AppColors.headerColor,
      automaticallyImplyLeading: false, // No back button
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // App Logo
          Image.asset(
            'assets/images/logo_simple.png',
            height: 40,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          // App Name
          const Text(
            'AïkiGrade',
            style: TextStyle(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}