import 'package:flutter/material.dart';
import '../../functions/config_service.dart';
import '../../functions/utils.dart';
import '../../constants/colors.dart';
import '../../widgets/text_input.dart';
import '../../widgets/drop_down_selection.dart';
import '../../widgets/scaffold_with_wide_bottom_panel.dart';
import '../../widgets/layouts/page_layout.dart';
import '../../widgets/confirm_dialog.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  ConfigScreenState createState() => ConfigScreenState();
}

class ConfigScreenState extends State<ConfigScreen> {
  String examDefaultName = 'Loading...';
  String examDefaultNameNew = '';
  int timePerTechnique = 60;
  int timePerTechniqueNew = 60;
  String prioritizeBy = 'Attack';
  String prioritizeByNew = 'Attack';
  int numberOfTechniquePerAttack = 2;
  int numberOfTechniquePerAttackNew = 2;

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
      timePerTechnique = ConfigService.getConfig('timePerTechnique') ?? 60;
      prioritizeBy = toTitleCase(ConfigService.getConfig('prioritizeBy') ?? 'Attack');
      numberOfTechniquePerAttack = ConfigService.getConfig('numberOfTechniquePerAttack') ?? 2;

      timePerTechniqueNew = timePerTechnique;
      prioritizeByNew = prioritizeBy;
      numberOfTechniquePerAttackNew = numberOfTechniquePerAttack;
    });
  }

  // Save updated configurations
  void _saveConfig() {
    ConfigService.setConfig('examDefaultName', examDefaultNameNew);
    ConfigService.setConfig('timePerTechnique', timePerTechniqueNew);
    ConfigService.setConfig('prioritizeBy', prioritizeByNew.toLowerCase());
    ConfigService.setConfig('numberOfTechniquePerAttack', numberOfTechniquePerAttackNew);
    ConfigService.saveConfig();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuration saved successfully!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithWideBottomPanel(
      body: PageLayout(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - 140, // minus bottom panel height
          ),
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
          
              Center(
                child: ValueSelectionWidget<int>(
                  selectedValue: timePerTechniqueNew,
                  onValueChanged: (int newValue) {
                    setState(() {
                      timePerTechniqueNew = newValue;
                    });
                  },
                  valuesList: [10, 15, 20, 25, 30, 40, 60, 90, 120, 180],
                  hintText: "Select Time in seconds per technique",
                  titleText: "Time per Technique",
                ),
              ),
          
              const SizedBox(height: 20),
          
              Center(
                child: ValueSelectionWidget<String>(
                  selectedValue: prioritizeByNew,
                  onValueChanged: (String newValue) {
                    setState(() {
                      prioritizeByNew = newValue;
                    });
                  },
                  valuesList: ["Attack", "Technique"],
                  hintText: "Select if technique should be prioritized by",
                  titleText: "Prioritize By",
                ),
              ),
          
              const SizedBox(height: 20),
          
              Center(
                child: ValueSelectionWidget<int>(
                  selectedValue: numberOfTechniquePerAttackNew,
                  onValueChanged: (int newValue) {
                    setState(() {
                      numberOfTechniquePerAttackNew = newValue;
                    });
                  },
                  valuesList: [1, 2, 3, 4, 5],
                  hintText: "Select the maximum number of techniques per attack",
                  titleText: "Max Number of Technique per Attack",
                ),
              ),
          
              const SizedBox(height: 20),
          
              ElevatedButton(
                onPressed: _saveConfig,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: AppColors.textColor,
                  backgroundColor: AppColors.buttonColor,
                ),
                child: const Text('Save Configuration'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                ),
                onPressed: () async {
                  final confirm = await showConfirmDialog(
                    context: context,
                    title: 'Reset data',
                    content:
                        'This will permanently delete all your local data. This action cannot be undone.',
                    confirmText: 'Delete',
                    confirmColor: Colors.red,
                  );

                  if (confirm == true) {
                    await resetData();
                  }
                },
                child: const Text('Reset local data'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
