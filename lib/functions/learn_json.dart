import 'package:aikido_helper/functions/technique_load_files.dart';
import 'package:logger/logger.dart';
import 'package:aikido_helper/functions/exam_json.dart';
import 'package:aikido_helper/functions/utils.dart';

final Logger logger = Logger();

Future<String> createLearnJsonFile({
  required String path,
}) async {
  try {
    final allTech = await loadAllTechniques(path, '1 Kyu');
    final allExams = await loadExamFiles();

    // Prepare a map for quick lookup: (waza, attack, technique, form) -> index in allTech
    final Map<String, Map<String, dynamic>> learnList = {};
    int index = 0;
    for (int i = 0; i < allTech.length; i++) {
      final technique = allTech[i];
      final key = '${technique['waza']}|${technique['attack']}|${technique['technique']}|${technique['form']}';
      learnList[key] = {
        "waza": technique.waza,
        "attack": technique.attack,
        "technique": technique.technique,
        "form": technique.form,
        "techniqueGrade": technique.grade,
        "links": technique.links,
        "markdown": technique.markdown,
        "progression": [],
        "index": index,
      };
      index++;
    }

    for (final examFile in allExams) {
      final currentExamData = await getJsonData(fileName: examFile);
      final currentEvaluation = currentExamData["evaluation"];
      final examDate = currentExamData["metadata"]["date"];
      final examHour = currentExamData["metadata"]["hour"];
      final dateHour = '$examDate $examHour';

      for (final technique in currentEvaluation) {
        final key = '${technique["waza"]}|${technique["attack"]}|${technique["technique"]}|${technique["form"]}';
        final rating = technique["rating"];
        if (learnList.containsKey(key) && learnList[key] != null) {
          // Append progression entry
          (learnList[key]!["progression"] as List).add({
            "date": dateHour,
            "rating": rating,
          });
        }
      }
    }

    final String safeFileName = 'learningJson';
    await saveJsonData(fileName: safeFileName, jsonData: learnList);
    return safeFileName;
  } catch (e, stack) {
    throw Exception("Failed to create learn JSON: $e\n$stack");
  }
}

Future<String> updateLearnJsonFile({
  required String learnFile,
  required String examFile,
}) async {
  try {
    final learnList = await getJsonData(fileName: learnFile);

    final currentExamData = await getJsonData(fileName: examFile);
    final currentEvaluation = currentExamData["evaluation"];
    final examDate = currentExamData["metadata"]["date"];
    final examHour = currentExamData["metadata"]["hour"];
    final dateHour = '$examDate $examHour';

    for (final technique in currentEvaluation) {
      final key = '${technique["waza"]}|${technique["attack"]}|${technique["technique"]}|${technique["form"]}';
      final rating = technique["rating"];
      if (learnList.containsKey(key) && learnList[key] != null && rating != 0) {
        // Append progression entry
        (learnList[key]!["progression"] as List).add({
          "date": dateHour,
          "rating": rating,
        });
      }
    }

    final String safeFileName = 'learningJson';
    await saveJsonData(fileName: safeFileName, jsonData: learnList);
    return safeFileName;
  } catch (e, stack) {
    throw Exception("Failed to update learn JSON: $e\n$stack");
  }
}

int compareTechniques(Map<String, dynamic> a, Map<String, dynamic> b, String sortField, bool ascending) {
  dynamic getField(Map<String, dynamic> t, String field) {
    switch (field) {
      case 'rating':
        return (t['progression'].isNotEmpty)
            ? (t['progression'].last['rating'] as num?) ?? 0
            : 0;
      case 'grade':
        return t['techniqueGrade'] ?? '';
      case 'waza':
        return t['waza'] ?? '';
      case 'attack':
        return t['attack'] ?? '';
      case 'technique':
        return t['technique'] ?? '';
      default:
        return '';
    }
  }

  final valA = getField(a, sortField);
  final valB = getField(b, sortField);

  if (valA is num && valB is num) {
    return ascending ? valA.compareTo(valB) : valB.compareTo(valA);
  }
  return ascending
      ? valA.toString().compareTo(valB.toString())
      : valB.toString().compareTo(valA.toString());
}
