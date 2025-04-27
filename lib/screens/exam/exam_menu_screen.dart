import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../routes.dart';
import '../../widgets/drop_down_selection.dart';
import '../../widgets/text_input.dart';
import '../../functions/exam_json.dart';

class ExamMenuScreen extends StatefulWidget {
  const ExamMenuScreen({super.key});

  @override
  _ExamMenuScreenState createState() => _ExamMenuScreenState();
}

class _ExamMenuScreenState extends State<ExamMenuScreen> {
  String selectedGrade = '5 Kyu';
  String examName = '';
  String examNameDefault = 'My Exam';

  final List<String> gradesList = ['5 Kyu', '4 Kyu', '3 Kyu', '2 Kyu', '1 Kyu', '1 Dan', '2 Dan'];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Aikido Exam Helper"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Let's Start Your Exam",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),

            const SizedBox(height: 20),

            // Get exam name from user
            TextInput(
              onChanged: (value) {
                examName = value;
              },
              hintText: "Enter Exam Name",
              title: "Exam Name",
              initialValue: examNameDefault,
            ),

            const SizedBox(height: 20),

            ValueSelectionWidget(
              selectedValue: selectedGrade,
              onValueChanged: (newGrade) {
                setState(() {
                  selectedGrade = newGrade; // Update the selected grade
                });
              },
              valuesList: gradesList,  // Pass list of grades to the widget
            ),

            const SizedBox(height: 50),

            // Start Button
            ElevatedButton(
              onPressed: () async {
                final examFile = await createExamJsonFile(
                  grade: selectedGrade,
                  examName: examName.isNotEmpty ? examName : examNameDefault,
                ).timeout(const Duration(seconds: 5));
                Navigator.pushNamed(
                  context,
                  AppRoutes.countdown,
                  arguments: {
                    'examFile': examFile,
                  }
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50), // Full width
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: AppColors.textColor, // Text color
                backgroundColor: AppColors.buttonColor, // Button color
              ),
              child: const Text(
                "Start Exam",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
