import 'package:flutter/material.dart';

class ValueSelectionWidget<T> extends StatelessWidget {
  final T selectedValue;
  final ValueChanged<T> onValueChanged;
  final List<T> valuesList;
  final String hintText;
  final String titleText;
  final double width;

  const ValueSelectionWidget({
    super.key,
    required this.selectedValue,
    required this.onValueChanged,
    required this.valuesList,
    required this.hintText,
    required this.titleText,
    this.width = 300.0, // Default width for the dropdown menu
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Title
        Text(
          titleText,
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        // Value Selection Dropdown
        SizedBox(
        width: width,
        child: DropdownButton<T>(
            value: selectedValue,
            onChanged: (T? newValue) {
              if (newValue != null) {
                onValueChanged(newValue);
              }
            },
            items: valuesList.map<DropdownMenuItem<T>>((T value) {
              return DropdownMenuItem<T>(
                value: value,
                child: Center(child: Text(value.toString())),
              );
            }).toList(),
            hint: Text(hintText),
            alignment: Alignment.center,
            isExpanded: true,
          ),
        ),
      ],
    );
  }
}
