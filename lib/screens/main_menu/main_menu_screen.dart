import 'package:flutter/material.dart';
import '../../widgets/scaffold_with_wide_bottom_panel.dart';
import '../../routes.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithWideBottomPanel(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: const Text(
                'Home',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 32),

            // Two columns side-by-side
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.examMenu),
                    child: Column(
                      children: [
                        Image.asset('assets/images/exam.png', height: 200),
                        const SizedBox(height: 8),
                        const Text('Exam', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.learnMenu),
                    child: Column(
                      children: [
                        Image.asset('assets/images/train.png', height: 200),
                        const SizedBox(height: 8),
                        const Text('Train', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
