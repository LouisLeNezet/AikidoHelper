import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import '../../routes.dart';
import '../../constants/colors.dart';
import '../../functions/exam_json.dart';
import '../../functions/utils.dart';
import '../../widgets/scaffold_with_wide_bottom_panel.dart';
import '../../widgets/page_layout.dart';

class ProgressionListScreen extends StatefulWidget {
  const ProgressionListScreen({super.key});

  @override
  State<ProgressionListScreen> createState() => _ProgressionListScreenState();
}

class _ProgressionListScreenState extends State<ProgressionListScreen> {
  late Future<List<String>> _examFilesFuture;

  final logger = Logger();

  @override
  void initState() {
    super.initState();
    _examFilesFuture = loadExamFiles();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithWideBottomPanel(
      body: FutureBuilder<List<String>>(
        future: _examFilesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading exams: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No exam yet available.'));
          }

          final examFiles = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: examFiles.length,
            itemBuilder: (context, index) {
              final fileName = examFiles[index];

              return FutureBuilder<Map<String, String>>(
                future: Future.wait([
                  getExamMetadataKey<String>(fileName: fileName, key: 'examName'),
                  getExamMetadataKey<String>(fileName: fileName, key: 'date'),
                  getExamMetadataKey<String>(fileName: fileName, key: 'hour'),
                  getExamMetadataKey<String>(fileName: fileName, key: 'grade'),
                ]).then((values) => {
                  'examName': values[0],
                  'date': values[1],
                  'hour': values[2],
                  'grade': values[3],
                }),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox(
                      height: 80,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final metadata = snapshot.data!;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(metadata['examName']!),
                      subtitle: Text(
                        'Date: ${metadata['date']}\nHour: ${metadata['hour']}\nGrade: ${metadata['grade']}',
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.progressionDetail,
                          arguments: {'fileName': fileName},
                        );
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Exam'),
                              content: const Text('Are you sure?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await deleteExamFile(fileName); // 👈 extract logic (see below)
                            setState(() {
                              _examFilesFuture = loadExamFiles();
                            });
                          }
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
