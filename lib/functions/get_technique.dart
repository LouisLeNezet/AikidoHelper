import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';

Future<List<List<String>>> getAllTechniques({
  required String path,
  required String grade,
  AssetBundle? bundle,
}) async {
  final effectiveBundle = bundle ?? rootBundle;
  try {
    // Load the CSV data
    final csvData = await effectiveBundle.loadString(path);
    final lines = LineSplitter.split(csvData).toList();

    if (lines.isEmpty) {
      throw Exception("The CSV file is empty.");
    }

    final rows = lines.map((line) => line.split('\t')).toList();

    // Predefined grade order
    const gradeOrder = ['5 Kyu', '4 Kyu', '3 Kyu', '2 Kyu', '1 Kyu', '1 Dan', '2 Dan'];

    final gradeIndex = gradeOrder.indexOf(grade);
    if (gradeIndex == -1) {
      throw Exception("Invalid grade: $grade");
    }

    // Skip header row and filter rows
    final filtered = rows.skip(1).where((row) {
      if (row.length < 5) return false;
      final rowGrade = row.last;
      final rowGradeIndex = gradeOrder.indexOf(rowGrade);
      return rowGradeIndex != -1 && rowGradeIndex <= gradeIndex;
    }).toList();

    if (filtered.isEmpty) {
      throw Exception("No matching techniques for grade $grade");
    }

    return filtered;

  } catch (e, stack) {
    throw Exception("Failed to load technique: $e\n$stack");
  }
}

Future<Map<String, Map<String, int>>> loadOrderingFromCSV(String orderCsvPath) async {
  final csvData = await rootBundle.loadString(orderCsvPath);
  final lines = LineSplitter.split(csvData).skip(1); // Skip header
  final Map<String, Map<String, int>> orders = {
    'Attack': {},
    'Position': {},
    'Technique': {},
    'Form': {},
  };

  for (final line in lines) {
    final parts = line.split('\t');
    if (parts.length < 3) continue;
    final name = parts[0].trim();
    final type = parts[1].trim();
    final order = int.tryParse(parts[2].trim()) ?? 999;

    if (orders.containsKey(type)) {
      orders[type]![name.toLowerCase()] = order;
    }
  }

  return orders;
}

int orderCompare(String a, String b, Map<String, int> orderMap) {
  return (orderMap[a.toLowerCase()] ?? 999)
      .compareTo(orderMap[b.toLowerCase()] ?? 999);
}

Future<List<List<String>>> getOrderedTechniques({
  required String path,
  required String grade,
}) async {
  final orders = await loadOrderingFromCSV('assets/technique/technique_ordering.csv');
  final attackOrder = orders['Attack']!;
  final positionOrder = orders['Position']!;
  final techniqueOrder = orders['Technique']!;
  final formOrder = orders['Form']!;

  final filtered = await getAllTechniques(path: path, grade: grade);

  // Sort by position (first column) in ascending order
  filtered.sort((a, b) {
    final cmpPosition = orderCompare(a[0], b[0], positionOrder);
    if (cmpPosition != 0) return cmpPosition;

    final cmpAttack = orderCompare(a[1], b[1], attackOrder);
    if (cmpAttack != 0) return cmpAttack;

    final cmpTechnique = orderCompare(a[2], b[2], techniqueOrder);
    if (cmpTechnique != 0) return cmpTechnique;

    final formA = a.length > 3 ? a[3] : '';
    final formB = b.length > 3 ? b[3] : '';
    return orderCompare(formA, formB, formOrder);
  });

  return filtered;
}
