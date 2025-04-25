import 'package:flutter/material.dart';
import '../../routes.dart';
import 'package:aikido_helper/functions/get_technique.dart';

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

          final listTechnique = snapshot.data!;
          final position = listTechnique[0] as String;
          final attack = listTechnique[1] as String;
          final technique = listTechnique[2] as String;
          final form = listTechnique[3] as String;
          final techniqueGrade = listTechnique[4] as String;
          final maxIndex = listTechnique[5] as int;
          final isLast = index + 1 >= maxIndex;

          return Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          position,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          attack,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          technique,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          form,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 40),
                        Text(
                          techniqueGrade,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Technique: ${index + 1} / $maxIndex",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FloatingActionButton.extended(
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<List<dynamic>?> getTechniqueSafe(String grade, int index) async {
    final result = await getTechniqueNameFromCSV(
      path: 'assets/technique/technique.csv',
      grade: grade,
      index: index,
    );
    return result;
  }
}
