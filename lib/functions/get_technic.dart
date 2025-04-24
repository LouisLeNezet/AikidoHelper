import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';

Future<List<dynamic>?> getTechniqueNameFromCSV({
  required String path,
  required String grade,
  required int index,
}) async {
  try {
    // Load the CSV data
    final csvData = await rootBundle.loadString(path);
    final lines = LineSplitter.split(csvData).toList();

    if (lines.isEmpty) {
      return ["No data in CSV", 0];
    }

    final rows = lines.map((line) => line.split('\t')).toList();

    // Predefined grade order
    const gradeOrder = ['5', '4', '3', '2', '1', '1 Dan', '2 Dan'];

    final gradeIndex = gradeOrder.indexOf(grade);
    if (gradeIndex == -1) {
      return ["Invalid grade: $grade", 0];
    }

    // Skip header row and filter rows
    final filtered = rows.skip(1).where((row) {
      if (row.length < 5) return false;
      final rowGrade = row.last;
      final rowGradeIndex = gradeOrder.indexOf(rowGrade);
      return rowGradeIndex != -1 && rowGradeIndex <= gradeIndex;
    }).toList();

    if (filtered.isEmpty) {
      return ["No matching techniques for grade $grade", 0];
    }

    if (index >= filtered.length) {
      return ["Index out of range", filtered.length];
    }

    final row = filtered[index];
    final position = row[0];
    final attack = row[1];
    final technique = row[2];
    final form = row.length > 3 ? row[3] : '';

    // Return both the formatted technique name and the total number of filtered techniques
    return [
      "$position - $attack - $technique${form.isNotEmpty ? " - $form" : ""}",
      filtered.length,
    ];
  } catch (e, stack) {
    print("Error reading technique from CSV: $e\n$stack");
    return ["Failed to load technique", 0];
  }
}
