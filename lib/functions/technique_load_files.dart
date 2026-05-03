import '../../functions/technique_class.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

/// Loads all techniques up to and including [grade].
/// Grades ordered simplest → hardest.
Future<List<Technique>> loadAllTechniques(String path, String grade) async {
  final csv = await rootBundle.loadString(path);
  final lines = LineSplitter.split(csv).skip(1);
  const grades = ['5 Kyu','4 Kyu','3 Kyu','2 Kyu','1 Kyu'];
  final maxIdx = grades.indexOf(grade);
  if (maxIdx<0) throw 'Unknown grade $grade';

  return lines
    .map((l)=>l.split('\t'))
    .where((r) => grades.indexOf(r[4]) <= maxIdx)
    .map((r)=>Technique(
      waza: r[0],
      attack: r[1],
      technique: r[2],
      form: r[3],
      grade: r[4],
      links: r[5].split(','),
      markdown: r[6],
      progression: List.empty(),
    ))
    .toList();
}

/// Loads per-grade, per-position total available seconds.
Future<Map<String, Map<String,int>>> loadGradeTimes(String path) async {
  final csv = await rootBundle.loadString(path);
  final lines = LineSplitter.split(csv).skip(1);
  final out = <String,Map<String,int>>{};
  for (var l in lines) {
    final parts = l.split('\t');
    if (parts.length<3) continue;
    final g = parts[0], pos=parts[2];
    final t=int.tryParse(parts[1])??0;
    out.putIfAbsent(g,()=>{})[pos]=t;
  }
  return out;
}

/// Loads per-grade, per-position total available seconds.
Future<Map<String, Map<String,int>>> loadOrderTechnique(String path) async {
  final csv = await rootBundle.loadString(path);
  final lines = LineSplitter.split(csv).skip(1);
  final out = <String,Map<String,int>>{};
  for (var l in lines) {
    final parts = l.split('\t');
    if (parts.length<3) throw Exception("Invalid CSV format");
    final n = parts[0], t=parts[1];
    final o = int.tryParse(parts[2])??0;
    out.putIfAbsent(t,()=>{})[n]=o;
  }
  return out;
}