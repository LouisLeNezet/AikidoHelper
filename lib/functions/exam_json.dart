import 'dart:convert';
import 'dart:io';
import 'package:aikido_helper/functions/technique_class.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import './technique_filter.dart';
import './config_service.dart';
import './utils.dart';

Future<String> createExamJsonFile({
  required String grade,
  required String examName,
  Future<String> Function()? getAppVersionFn,
  Future<List<Technique>> Function({required String path, required String grade, required String gradeTimeCsvPath})? subsetTechniquesFn,
}) async {
  try {
    final appVersion = await (getAppVersionFn?.call() ?? getAppVersion());

    final now = DateTime.now();
    final String date = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final String hour = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    // Use your getOrderedTechniques function
    final techniques = await (
      subsetTechniquesFn?.call(path: 'assets/technique/techniques.csv', grade: grade, gradeTimeCsvPath: 'assets/technique/grade_time.csv') ?? 
      subsetTechniques(path: 'assets/technique/techniques.csv', grade: grade, gradeTimeCsvPath: 'assets/technique/grade_time.csv')
    );

    final List<Map<String, dynamic>> evaluationList = [];

    final timePerTechnique = ConfigService.getConfig('timePerTechnique') ?? 60;

    int index = 1;
    for (final technique in techniques) {
      evaluationList.add({
        "position": technique.position,
        "attack": technique.attack,
        "technique": technique.technique,
        "form": technique.form,
        "techniqueGrade": technique.grade,
        "duration": timePerTechnique,
        "evaluation": "",
        "index": index++,
      });
    }

    final tachi = techniques.where((t) => t.position == 'Tachi waza');
    final suwari = techniques.where((t) => t.position == 'Suwari waza');
    final hanmi = techniques.where((t) => t.position == 'Hanmi Handachi waza');

    // Final JSON structure
    final Map<String, dynamic> examJson = {
      "metadata": {
        "date": date,
        "hour": hour,
        "grade": grade,
        "examName": examName,
        "version": appVersion,
        "size": {
          "Suwari waza": suwari.length,
          "Hanmi Handachi waza": hanmi.length,
          "Tachi waza": tachi.length,
          "total": techniques.length
        }
      },
      "evaluation": evaluationList,
    };

    // Save JSON to file
    final String safeExamName = examName.replaceAll(' ', '_'); // Avoid spaces in filenames
    final String dateTimePrefix = '${date.replaceAll('-', '_')}_${hour.replaceAll(':', '_')}';
    final String safeFileName = 'exam_${dateTimePrefix}_$safeExamName';

    if (kIsWeb) {
      // WEB: Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(safeFileName, jsonEncode(examJson));
      return safeFileName; // Return a dummy file reference
    } else {
      // MOBILE: Save to file
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String filePath = '${appDocDir.path}/$safeFileName.json';
      final File file = File(filePath);

      await file.writeAsString(jsonEncode(examJson), flush: true);
      return safeFileName;
    }
  } catch (e, stack) {
    throw Exception("Failed to create exam JSON: $e\n$stack");
  }
}

Future <Map<String, dynamic>> getExamJsonData({
  required String fileName,
}) async {
  try {
    late String content;
    if (kIsWeb) {
      // WEB: Load from local storage
      final prefs = await SharedPreferences.getInstance();
      content = prefs.getString(fileName) ?? '';
      if (content.isEmpty) {
        throw Exception('Exam file not found in local storage.');
      }
    } else {
      // MOBILE: Load from file
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String filePath = '${appDocDir.path}/$fileName.json';
      final File jsonFile = File(filePath);
      if (!jsonFile.existsSync()) {
        throw Exception('Exam file not found at $filePath.');
      }
      content = await jsonFile.readAsString();
    }

    final Map<String, dynamic> data = jsonDecode(content);

    if (data case {'metadata': Map<String, dynamic> _, 'evaluation': List _}) {
      return data;
    } else {
      throw Exception('Invalid exam file: missing required fields.');
    }
  } catch (e, stack) {
    throw Exception('Failed to get exam JSON data: $e\n$stack');
  }
}

Future<Map<String, dynamic>> getTechniqueByIndex({
  required String fileName,
  required int index,
}) async {
  try {
    final Map<String, dynamic> data = await getExamJsonData(fileName: fileName);

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


Future<Map<String, dynamic>> getExamMetaData({required String fileName}) async {
  try {
    final Map<String, dynamic> data = await getExamJsonData(fileName: fileName);

    if (data.containsKey('metadata') && data['metadata'] is Map<String, dynamic>) {
      final metadata = data['metadata'] as Map<String, dynamic>;
      return metadata;
    } else {
      throw Exception('Invalid exam file: missing "metadata" section.');
    }
  } catch (e, stack) {
    throw Exception('Failed to get exam length: $e\n$stack');
  }
}

Future<T> getExamMetadataKey<T>({
  required String fileName,
  required String key
}) async {
  try {
    final metadata = await getExamMetaData(fileName: fileName);

    if (!metadata.containsKey(key)) {
      throw Exception('Metadata does not contain key "$key".');
    }

    final value = metadata[key];
    if (value.runtimeType != T) {
      throw Exception('Expected "$key" to be of type $T, but got ${value.runtimeType}.');
    }

    return value;
  } catch (e, stack) {
    throw Exception('Failed to get exam $key: $e\n$stack');
  }
}

Future<Map<String, dynamic>> getTechniqueAndExamSize({
  required String fileName,
  required int index,
}) async {
  try {
    final technique = await getTechniqueByIndex(fileName: fileName, index: index);
    final metadata = await getExamMetaData(fileName: fileName);
    final sizeExam = metadata['size']['total'] as int;

    return {
      'technique': technique,
      'sizeExam': sizeExam,
    };
  } catch (e, stack) {
    throw Exception('Failed to get technique and size: $e\n$stack');
  }
}
