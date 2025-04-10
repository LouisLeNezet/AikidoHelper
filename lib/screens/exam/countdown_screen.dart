import 'package:flutter/material.dart';
import '../../widgets/countdown_timer.dart'; // Import the CountdownTimer widget
import '../../routes.dart';

class CountdownScreen extends StatelessWidget {
  const CountdownScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Countdown'),
      ),
      body: CountdownTimer(
        duration: 5, // Set the countdown duration here (in seconds)
        onFinish: () {
          Navigator.pushReplacementNamed(context, AppRoutes.evaluation); // Navigate to the next screen when finished
        },
      ),
    );
  }
}
