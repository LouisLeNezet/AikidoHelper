import 'package:flutter/material.dart';
import '../../widgets/countdown_timer.dart';
import '../../routes.dart';

class CountdownScreen extends StatelessWidget {
  final String selectedGrade;

  const CountdownScreen({
    super.key,
    required this.selectedGrade,
  }); // Update constructor

  @override
  Widget build(BuildContext context) {
    final grade = selectedGrade.isNotEmpty ? selectedGrade : '5';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Countdown'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'The exam will start in:',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          CountdownTimer(
            duration: 5,
            onFinish: () {
              Navigator.pushNamed(
                context,
                AppRoutes.evaluation,
                arguments: {
                  'grade': grade,
                  'index': 0,
                },
              );
            },
          ),
          const SizedBox(height: 32),
          Center(
            child: Text('Selected grade: $selectedGrade'),
          ),
        ],
      ),
    );
  }
}
