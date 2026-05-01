import 'package:flutter/material.dart';
import '../../functions/exam_json.dart';
import '../../routes.dart';
import '../../widgets/scaffold_with_wide_bottom_panel.dart';
import 'package:logger/logger.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class EvaluationScreen extends StatefulWidget {
  final String fileName;
  final int index;

  const EvaluationScreen({
    super.key,
    required this.fileName,
    required this.index,
  });

  @override
  State<EvaluationScreen> createState() => _EvaluationScreenState();
}

class _EvaluationScreenState extends State<EvaluationScreen> {
  double _currentRating = 3;

  Future<void> _saveRating(double rating) async {
    await saveTechniqueRating(
      fileName: widget.fileName,
      index: widget.index,
      rating: rating,
    );
  }

  final logger = Logger();

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithWideBottomPanel(
      showWidePanel: false,
      body: FutureBuilder<Map<String, dynamic>?>(
        future: getTechniqueSafe(widget.fileName, widget.index),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text("No data found", style: TextStyle(color: Colors.red)),
            );
          }

          final maxIndex = snapshot.data!['sizeExam'] - 1 as int;
          final isLast = widget.index == maxIndex;

          final techniqueData = snapshot.data!['technique'] as Map<String, dynamic>;
          final position = techniqueData['position'] as String;
          final attack = techniqueData['attack'] as String;
          final technique = techniqueData['technique'] as String;
          final form = techniqueData['form'] as String? ?? '';
          final techniqueGrade = techniqueData['techniqueGrade'] as String;
          final nextWazaIndex = techniqueData['nextWazaIndex'] as int?;
          final nextAttackIndex = techniqueData['nextAttackIndex'] as int?;

          logger.d(techniqueData);

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
                          "Technique: ${widget.index} / $maxIndex",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  RatingBar.builder(
                    initialRating: 3,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      switch (index) {
                          case 0:
                            return Icon(
                                Icons.sentiment_very_dissatisfied,
                                color: Colors.red,
                            );
                          case 1:
                            return Icon(
                                Icons.sentiment_dissatisfied,
                                color: Colors.redAccent,
                            );
                          case 2:
                            return Icon(
                                Icons.sentiment_neutral,
                                color: Colors.amber,
                            );
                          case 3:
                            return Icon(
                                Icons.sentiment_satisfied,
                                color: Colors.lightGreen,
                            );
                          case 4:
                              return Icon(
                                Icons.sentiment_very_satisfied,
                                color: Colors.green,
                              );
                          default:
                            return Icon(
                              Icons.sentiment_neutral,
                              color: Colors.grey,
                            );
                      }
                    },
                    onRatingUpdate: (rating) {
                      _currentRating = rating;
                    },
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (nextWazaIndex != null) ...[
                          FloatingActionButton.extended(
                            onPressed: () async {
                              await _saveRating(_currentRating);
                              if (!mounted) return;
                              Navigator.pushReplacementNamed(
                                context,
                                AppRoutes.evaluation,
                                arguments: {
                                'fileName': widget.fileName,
                                'index': nextWazaIndex,
                                },
                              );
                            },
                            label: const Text('Next Waza'),
                            icon: const Icon(Icons.skip_next),
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (nextAttackIndex != null) ...[
                          FloatingActionButton.extended(
                              onPressed: () async {
                                await _saveRating(_currentRating);
                                if (!mounted) return;
                                Navigator.pushReplacementNamed(
                                  context,
                                  AppRoutes.evaluation,
                                  arguments: {
                                  'fileName': widget.fileName,
                                  'index': nextAttackIndex,
                                  },
                                );
                              },
                              label: const Text('Next Attack'),
                              icon: const Icon(Icons.skip_next),
                            ),
                          const SizedBox(width: 12),
                        ],
                        FloatingActionButton.extended(
                          onPressed: () async {
                            await _saveRating(_currentRating);
                            if (!mounted) return;
                            if (isLast) {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.progressionDetail,
                                arguments: {'fileName': widget.fileName},
                              );
                            } else {
                              Navigator.pushReplacementNamed(
                                context,
                                AppRoutes.evaluation,
                                arguments: {
                                'fileName': widget.fileName,
                                'index': widget.index + 1,
                                },
                              );
                            }
                          },
                          label: Text(isLast ? 'Finish Exam' : 'Next'),
                          icon: Icon(isLast ? Icons.check : Icons.navigate_next),
                        ),
                      ],
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
