import '../../functions/config_service.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

Future<String> getAppVersion() async {
  await ConfigService.loadConfig();
  final appVersion = ConfigService.getConfig('appVersion');
  return appVersion;
}

String toTitleCase(String input) {
  if (input.isEmpty) return input;
  return input.split(' ').map((word) {
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}

Future <Map<String, dynamic>> getJsonData({
  required String fileName,
}) async {
  try {
    late String content;
    if (kIsWeb) {
      // WEB: Load from local storage
      final prefs = await SharedPreferences.getInstance();
      content = prefs.getString(fileName) ?? '';
      if (content.isEmpty) {
        throw Exception('JSON file not found in local storage.');
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
    return data;
  } catch (e, stack) {
    throw Exception('Failed to get exam JSON data: $e\n$stack');
  }
}


Future saveJsonData({
  required Map<String, dynamic> jsonData,
  required String fileName,
}) async {
  try {
    if (kIsWeb) {
      // WEB: Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(fileName, jsonEncode(jsonData));
    } else {
      // MOBILE: Save to file
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String filePath = '${appDocDir.path}/$fileName.json';
      final File file = File(filePath);

      await file.writeAsString(jsonEncode(jsonData), flush: true);
    }
  } catch (e, stack) {
    throw Exception('Failed to write JSON data: $e\n$stack');
  }
}
