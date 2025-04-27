import 'package:flutter/material.dart';
import 'dart:io';
import '../../routes.dart';
import '../../constants/colors.dart';
import 'dart:convert';

class ProgressionDetailScreen extends StatefulWidget {
  final File examFile;

  const ProgressionDetailScreen({
    required this.examFile,
    Key? key
  }) : super(key: key);

  @override
  State<ProgressionDetailScreen> createState() => _ProgressionDetailScreenState();
}

class _ProgressionDetailScreenState extends State<ProgressionDetailScreen> {
  late Future<Map<String, dynamic>> _examData;

  @override
  void initState() {
    super.initState();
    _examData = _loadExamData();
  }

  Future<Map<String, dynamic>> _loadExamData() async {
    final String content = await widget.examFile.readAsString();
    final Map<String, dynamic> data = jsonDecode(content);
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progression Details')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _examData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading exam: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data found.'));
          }

          final metadata = snapshot.data!['metadata'] as Map<String, dynamic>;
          final evaluationList = List<Map<String, dynamic>>.from(snapshot.data!['evaluation']);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Date: ${metadata['date']}'),
              Text('Hour: ${metadata['hour']}'),
              Text('Grade: ${metadata['grade']}'),
              Text('Exam Name: ${metadata['examName']}'),
              Text('App Version: ${metadata['version']}'),
              Text('Size: ${metadata['size']} techniques'),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              const Text('Techniques:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...evaluationList.map((technique) => Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text('${technique['position']} - ${technique['technique']}'),
                  subtitle: Text('Attack: ${technique['attack']}\nForm: ${technique['form']} | Grade: ${technique['techniqueGrade']}'),
                  trailing: Text('Index: ${technique['index']}'),
                ),
              )),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.mainMenu);
                },
                style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: AppColors.textColor,
                      backgroundColor: AppColors.buttonColor,
                    ),
                child: const Text('Back to Menu'),
              ),
            ],
          );
        },
      ),
    );
  }
}
