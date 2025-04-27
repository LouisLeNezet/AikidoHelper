import 'package:flutter/material.dart';
import '../../widgets/countdown_timer.dart';
import '../../routes.dart';

class CountdownScreen extends StatelessWidget {
  final String fileName;

  const CountdownScreen({
    super.key,
    required this.fileName,
  }); // Update constructor

  @override
  Widget build(BuildContext context) {
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
                  'fileName': fileName,
                  'index': 1,
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
