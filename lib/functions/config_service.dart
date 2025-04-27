import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ConfigService {
  static Map<String, dynamic> _config = {};

  // Load configuration from the assets or from the saved file
  static Future<void> loadConfig() async {
    try {
      if (kIsWeb) {
        // On web, load from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        String? savedConfig = prefs.getString('user_config');
        if (savedConfig != null) {
          _config = jsonDecode(savedConfig);
        } else {
          // If no user config exists, load from assets
          await _loadConfigFromAssets();
          await saveConfig(); // Save to shared preferences for future use
        }
      } else {
        // On mobile, check for a saved config file
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final String filePath = '${appDocDir.path}/user_config.json';
        final File file = File(filePath);

        if (await file.exists()) {
          // If the file exists, load it
          String savedConfig = await file.readAsString();
          _config = jsonDecode(savedConfig);
        } else {
          // If the file doesn't exist, load from assets
          await _loadConfigFromAssets();
          await saveConfig(); // Save to file for future use
        }
      }
    } catch (e) {
      debugPrint('Error loading config: $e');
    }
  }

  // Helper function to load the default config from assets
  static Future<void> _loadConfigFromAssets() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/config.json');
      _config = jsonDecode(jsonString);
    } catch (e) {
      debugPrint('Error loading config from assets: $e');
    }
  }

  // Get a configuration value by key
  static dynamic getConfig(String key) {
    return _config[key];
  }

  // Set a configuration value
  static void setConfig(String key, dynamic value) {
    _config[key] = value;
  }

  // Save the configuration to a JSON file (for mobile) or SharedPreferences (for web)
  static Future<void> saveConfig() async {
    try {
      final String jsonString = jsonEncode(_config);
      if (kIsWeb) {
        // On Web, use SharedPreferences to save the config
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_config', jsonString);
      } else {
        // On mobile, use path_provider to save the config to a file
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final String filePath = '${appDocDir.path}/user_config.json';
        final File file = File(filePath);
        await file.writeAsString(jsonString, flush: true);
      }
    } catch (e) {
      debugPrint('Error saving config: $e');
    }
  }
}
