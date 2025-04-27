import 'dart:io';
import '../../routes.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../constants/colors.dart';
import '../../functions/exam_json.dart';

class ProgressionListScreen extends StatefulWidget {
  const ProgressionListScreen({super.key});

  @override
  State<ProgressionListScreen> createState() => _ProgressionListScreenState();
}

class _ProgressionListScreenState extends State<ProgressionListScreen> {
  late Future<List<FileSystemEntity>> _examFilesFuture;

  @override
  void initState() {
    super.initState();
    _examFilesFuture = _loadExamFiles();
  }

  Future<List<FileSystemEntity>> _loadExamFiles() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final List<FileSystemEntity> files = appDocDir.listSync();

    // Filter only .json files
    final examFiles = files.where((file) => file.path.endsWith('.json')).toList();
    return examFiles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progression List')),
      body: FutureBuilder<List<FileSystemEntity>>(
        future: _examFilesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading exams: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No exam found.'));
          }

          final examFiles = snapshot.data!;

          return ListView.builder(
            itemCount: examFiles.length,
            itemBuilder: (context, index) {
              final file = examFiles[index] as File;

              return FutureBuilder<Map<String, String>>(
                future: Future.wait([
                  getExamMetadataKey<String>(jsonFile: file, key: 'examName'),
                  getExamMetadataKey<String>(jsonFile: file, key: 'date'),
                  getExamMetadataKey<String>(jsonFile: file, key: 'hour'),
                  getExamMetadataKey<String>(jsonFile: file, key: 'grade'),
                ]).then((values) => {
                      'examName': values[0],
                      'date': values[1],
                      'hour': values[2],
                      'grade': values[3],
                    }),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error loading metadata: ${snapshot.error}'));
                  } else if (!snapshot.hasData) {
                    return const Center(child: Text('Metadata not found.'));
                  }

                  final metadata = snapshot.data!;
                  final examName = metadata['examName']!;
                  final date = metadata['date']!;
                  final hour = metadata['hour']!;
                  final grade = metadata['grade']!;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(examName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date: $date'),
                          Text('Hour: $hour'),
                          Text('Grade: $grade'),
                        ],
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.progressionDetail,
                          arguments: {'examFile': file},
                        );
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: AppColors.primaryColor),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Exam'),
                              content: const Text('Are you sure you want to delete this exam file?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel', style: TextStyle(color: AppColors.textColor)),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete', style: TextStyle(color: AppColors.primaryColor)),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await file.delete();
                            setState(() {
                              _examFilesFuture = _loadExamFiles(); // 🔥 RELOAD the list after deletion
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
