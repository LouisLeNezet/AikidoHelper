import 'package:flutter/material.dart';
import '../../routes.dart';
import 'package:aikido_helper/functions/exam_json.dart';

class EvaluationScreen extends StatelessWidget {
  final String fileName;
  final int index;

  const EvaluationScreen({
    super.key,
    required this.fileName,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Evaluate Technique")),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: getTechniqueSafe(fileName, index),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text("No data found", style: TextStyle(color: Colors.red)),
            );
          }

          final maxIndex = snapshot.data!['size'] as int;
          final isLast = index == maxIndex;

          final techniqueData = snapshot.data!['technique'] as Map<String, dynamic>;
          final position = techniqueData['position'] as String;
          final attack = techniqueData['attack'] as String;
          final technique = techniqueData['technique'] as String;
          final form = techniqueData['form'] as String? ?? '';
          final techniqueGrade = techniqueData['techniqueGrade'] as String;

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
                          "Technique: $index / $maxIndex",
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
                        Navigator.pushNamed(
                          context,
                          AppRoutes.progressionDetail, arguments: {
                            'fileName': fileName,
                          }
                        );
                      } else {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.evaluation,
                          arguments: {
                            'fileName': fileName,
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

  Future<Map<String, dynamic>?> getTechniqueSafe(String fileName, int index) async {
    final result = await getTechniqueAndExamSize(
      fileName: fileName,
      index: index,
    ).timeout(const Duration(seconds: 5));
    return result;
  }
}
