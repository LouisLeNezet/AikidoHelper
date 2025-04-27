import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import './get_technique.dart';
import './utils.dart';

Future<String> createExamJsonFile({
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
    final String safeExamName = examName.replaceAll(' ', '_'); // Avoid spaces in filenames
    final String dateTimePrefix = date.replaceAll('-', '_') + '_' + hour.replaceAll(':', '_'); 
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
    final size = await getExamMetadataKey<int>(fileName: fileName, key: 'size');

    return {
      'technique': technique,
      'size': size,
    };
  } catch (e, stack) {
    throw Exception('Failed to get technique and size: $e\n$stack');
  }
}
