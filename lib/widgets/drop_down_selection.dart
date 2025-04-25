import 'package:flutter/material.dart';

class ValueSelectionWidget extends StatelessWidget {
  final String selectedValue;
  final ValueChanged<String> onValueChanged;
  final List<String> valuesList;  // List of Values passed as input

  const ValueSelectionWidget({
    super.key,
    required this.selectedValue,
    required this.onValueChanged,
    required this.valuesList,  // Accepting list of Values
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Value Selection Dropdown
        DropdownButton<String>(
          value: selectedValue,
          onChanged: (String? newValue) {
            if (newValue != null) {
              onValueChanged(newValue);
            }
          },
          items: valuesList.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Center(child: Text(value)),
            );
          }).toList(),
          hint: const Text("Select Value"),
          alignment: Alignment.center, // Center the selected value
        ),
      ],
    );
  }
}
