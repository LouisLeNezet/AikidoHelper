import 'package:flutter/material.dart';
import '../../functions/config_service.dart';
import '../../constants/colors.dart';
import '../../widgets/text_input.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  ConfigScreenState createState() => ConfigScreenState();
}

class ConfigScreenState extends State<ConfigScreen> {
  String examDefaultName = 'Loading...';
  String examDefaultNameNew = '';

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  // Load configuration when the screen is initialized
  Future<void> _loadConfig() async {
    await ConfigService.loadConfig();
    setState(() {
      examDefaultName = ConfigService.getConfig('examDefaultName') ?? 'My Exam';
    });
  }

  // Save updated configurations
  void _saveConfig() {
    ConfigService.setConfig('examDefaultName', examDefaultNameNew);
    ConfigService.saveConfig();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuration saved successfully!')),
    );
    Navigator.pop(context); // Close the config screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Config Screen')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextInput(
              onChanged: (value) {
                  examDefaultNameNew = value;
              },
              hintText: "Enter Exam Name",
              title: "Exam Name",
              initialValue: examDefaultName,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveConfig,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50), // Full width
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: AppColors.textColor, // Text color
                backgroundColor: AppColors.buttonColor, // Button color
              ),
              child: const Text('Save Configuration'),
            ),
          ],
        ),
      ),
    );
  }
}
