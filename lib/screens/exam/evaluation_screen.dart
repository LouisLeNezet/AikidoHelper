import 'package:flutter/material.dart';

class EvaluationScreen extends StatelessWidget {
  const EvaluationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Evaluate Technique")),
      body: const Center(
        child: Text("This is where the evaluation will happen."),
      ),
    );
  }
}
