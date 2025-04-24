import 'package:flutter/material.dart';
import '../../routes.dart';
import 'package:aikido_helper/functions/get_technic.dart';

class EvaluationScreen extends StatelessWidget {
  final String grade;
  final int index;

  const EvaluationScreen({
    super.key,
    required this.grade,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Evaluate Technique")),
      body: FutureBuilder<List<dynamic>?>(
        future: getTechniqueSafe(grade, index),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text("No data found", style: TextStyle(color: Colors.red)),
            );
          }

          final listTechnic = snapshot.data!;
          final techniqueName = listTechnic[0] as String;
          final maxIndex = listTechnic[1] as int;
          final isLast = index + 1 >= maxIndex;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  techniqueName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 40),
              FloatingActionButton.extended(
                onPressed: () {
                  if (isLast) {
                    Navigator.pushReplacementNamed(context, AppRoutes.examSummary);
                  } else {
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.evaluation,
                      arguments: {
                        'grade': grade,
                        'index': index + 1,
                      },
                    );
                  }
                },
                label: Text(isLast ? 'Finish Exam' : 'Next'),
                icon: Icon(isLast ? Icons.check : Icons.navigate_next),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<List<dynamic>?> getTechniqueSafe(String grade, int index) async {
    print("Loading technique for grade: $grade at index: $index");
    final result = await getTechniqueNameFromCSV(
      path: 'assets/technic/technic.csv',
      grade: grade,
      index: index,
    );
    return result;
  }
}
