import 'dart:io';
import '../../routes.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../constants/colors.dart';
import '../../functions/exam_json.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

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
    _examFilesFuture = _loadExamFiles();
  }

  Future<List<String>> _loadExamFiles() async {
    if (kIsWeb) {
      // On the Web: Load from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      logger.d('Stored keys in SharedPreferences: $keys');

      // Filter keys to find those representing exam JSON files
      final examFiles = keys.where((key) => key.startsWith('exam_')).toList();
      return examFiles;
    } else {
      // On Mobile: Load from the filesystem
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final List<FileSystemEntity> files = appDocDir.listSync();

      logger.d("Files in appDocDir: $files");

      // Filter only .json files
      final examFiles = files
          .where((file) => file.path.endsWith('.json') && file.path.split('/').last.startsWith('exam_'))
            .map((file) => file.path.split('/').last.replaceAll('.json', ''))
          .toList();
      logger.d("Filtered exam files: $examFiles");
      return examFiles;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progression List')),
      body: FutureBuilder<List<String>>(
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
                          arguments: {'fileName': fileName},
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
                            if (kIsWeb) {
                              // Web: Remove from SharedPreferences (local storage)
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.remove(fileName);
                              setState(() {
                                _examFilesFuture = _loadExamFiles();
                              });
                            } else {
                              // Mobile: Delete file from filesystem
                              final Directory appDocDir = await getApplicationDocumentsDirectory();
                              final String filePath = '${appDocDir.path}/$fileName.json';
                              final File fileToDelete = File(filePath);
                              if (await fileToDelete.exists()) {
                                await fileToDelete.delete();
                                setState(() {
                                  _examFilesFuture = _loadExamFiles();  // Refresh the file list
                                });
                              }
                            }
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
