import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import './get_technique.dart';
import './utils.dart';

Future<File> createExamJsonFile({
  required String grade,
  required String examName,
  Future<String> Function()? getAppVersionFn,
  Future<List<List<String>>> Function({required String path, required String grade})? getOrderedTechniquesFn,
}) async {
  try {
    final appVersion = await (getAppVersionFn?.call() ?? getAppVersion());

    final now = DateTime.now();
    final String date = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final String hour = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    // Use your getOrderedTechniques function
    final techniques = await (
      getOrderedTechniquesFn?.call(path: 'assets/technique/technique.csv', grade: grade) ?? 
      getOrderedTechniques(path: 'assets/technique/technique.csv', grade: grade)
    );

    final List<Map<String, dynamic>> evaluationList = [];

    int index = 1;
    for (final technique in techniques) {
      evaluationList.add({
        "position": technique[0],
        "attack": technique[1],
        "technique": technique[2],
        "form": technique.length > 3 ? technique[3] : "",
        "techniqueGrade": technique.length > 4 ? technique[4] : "",
        "duration": 0,
        "evaluation": "",
        "index": index++,
      });
    }

    // Final JSON structure
    final Map<String, dynamic> examJson = {
      "metadata": {
        "date": date,
        "hour": hour,
        "grade": grade,
        "examName": examName,
        "version": appVersion,
        "size": techniques.length,
      },
      "evaluation": evaluationList,
    };

    // Save JSON to file
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String safeExamName = examName.replaceAll(' ', '_'); // Avoid spaces in filenames
    final String filePath = '${appDocDir.path}/$safeExamName.json';
    final File file = File(filePath);

    await file.writeAsString(jsonEncode(examJson), flush: true);
    return file;
  } catch (e, stack) {
    throw Exception("Failed to create exam JSON: $e\n$stack");
  }
}

Future<Map<String, dynamic>> getTechniqueByIndex({
  required File jsonFile,
  required int index,
}) async {
  try {
    final String content = await jsonFile.readAsString();
    final Map<String, dynamic> data = jsonDecode(content);

    if (!data.containsKey('evaluation') || data['evaluation'] is! List) {
      throw Exception('Invalid exam file: missing or bad "evaluation" section.');
    }

    final List<dynamic> evaluationList = data['evaluation'];

    final technique = evaluationList.firstWhere(
      (item) => item['index'] == index,
      orElse: () => throw Exception('No technique found for index $index.'),
    );

    return Map<String, dynamic>.from(technique);
  } catch (e, stack) {
    throw Exception('Failed to get technique: $e\n$stack');
  }
}

Future<int> getExamLength({required File jsonFile}) async {
  try {
    final String content = await jsonFile.readAsString();
    final Map<String, dynamic> data = jsonDecode(content);

    if (data.containsKey('metadata') && data['metadata'] is Map<String, dynamic>) {
      final metadata = data['metadata'] as Map<String, dynamic>;
      if (metadata.containsKey('size') && metadata['size'] is int) {
        return metadata['size'];
      } else {
        throw Exception('Metadata does not contain a valid "size" field.');
      }
    } else {
      throw Exception('Invalid exam file: missing "metadata" section.');
    }
  } catch (e, stack) {
    throw Exception('Failed to get exam length: $e\n$stack');
  }
}

Future<Map<String, dynamic>> getTechniqueAndExamSize({
  required File jsonFile,
  required int index,
}) async {
  try {
    final technique = await getTechniqueByIndex(jsonFile: jsonFile, index: index);
    final size = await getExamLength(jsonFile: jsonFile);

    return {
      'technique': technique,
      'size': size,
    };
  } catch (e, stack) {
    throw Exception('Failed to get technique and size: $e\n$stack');
  }
}
