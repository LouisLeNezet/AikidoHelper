import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:aikido_helper/functions/technique_filter.dart';
import 'package:aikido_helper/functions/config_service.dart';
import 'package:aikido_helper/functions/technique_class.dart';
import 'package:aikido_helper/functions/technique_load_files.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _FakePathProvider extends PathProviderPlatform {
  final String path;
  _FakePathProvider(this.path);

  @override
  Future<String?> getApplicationDocumentsPath() async => path;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Technique class', () {
    test('Technique constructor initializes properties correctly', () {
      final technique = Technique(
        position: 'Tachi waza',
        attack: 'Katate dori',
        technique: 'Nikyo',
        form: 'Ura',
        grade: '4 Kyu',
      );

      expect(technique.position, 'Tachi waza');
      expect(technique.position, technique['position']);
      expect(technique.attack, 'Katate dori');
      expect(technique.attack, technique['attack']);
      expect(technique.technique, 'Nikyo');
      expect(technique.technique, technique['technique']);
      expect(technique.form, 'Ura');
      expect(technique.form, technique['form']);
      expect(technique.grade, '4 Kyu');
      expect(technique.grade, technique['grade']);
    });

    test('Technique toString returns formatted string', () {
      final technique = Technique(
        position: 'Tachi waza',
        attack: 'Katate dori',
        technique: 'Nikyo',
        form: 'Ura',
        grade: '4 Kyu',
      );

      expect(technique.toString(), 
        'Tachi waza Katate dori Nikyo Ura, grade: 4 Kyu)');
    });
  });

  group('load files', () {
    test('loadAllTechniques returns techniques up to given grade', () async {
      final techniques = await loadAllTechniques('assets/technique/techniques.csv', '4 Kyu');

      expect(techniques, isNotEmpty);
      expect(techniques.every((t) => 
        ['5 Kyu', '4 Kyu'].contains(t.grade)), isTrue);
    });

    test('loadGradeTimes returns time per grade', () async {
      final timegrade = await loadGradeTimes('assets/technique/grade_time.csv');

      expect(timegrade, isA<Map<String, Map<String, int>>>());
      expect(timegrade.containsKey('5 Kyu'), isTrue);
      expect(timegrade['5 Kyu']!.containsKey('Tachi waza'), isTrue);
      expect(timegrade['5 Kyu']!['Tachi waza'], 600);
    });

    test('loads and parses ordering correctly from CSV', () async {
      final result = await loadOrderTechnique('assets/technique/techniques_ordering.csv');

      expect(result, isA<Map<String, Map<String, int>>>());
      // Example assertions, change based on your CSV content
      expect(result.containsKey('Attack'), isTrue);
      expect(result['Attack']!.containsKey('Shomen uchi'), isTrue);
      expect(result['Attack']!['Shomen uchi'], 10);

      expect(result['Position']!.containsKey('Tachi waza'), isTrue);
      expect(result['Position']!['Tachi waza'], 3);
    });
  });

  test('orderCompare', () async {
    final orderMap = {
      'a': 1,
      'b': 2,
      'c': 3,
    };

    expect(orderCompare('a', 'b', orderMap), lessThan(0));
    expect(orderCompare('b', 'A', orderMap), greaterThan(0));
    expect(orderCompare('C', 'c', orderMap), equals(0));
  });

  test('orderTechniques', () async {
    final techniques = await loadAllTechniques('assets/technique/techniques.csv', '4 Kyu');
    final orderedTechniques = await orderTechniques(lstTechniques: techniques);
    
    expect(orderedTechniques, isNotEmpty);

    expect(orderedTechniques[0].position, 'Tachi waza');
    expect(orderedTechniques[0].attack, 'Katate dori');
    expect(orderedTechniques[0].technique, 'Nikyo');
    expect(orderedTechniques[0].form, 'Ura');
    expect(orderedTechniques[0].grade, '4 Kyu');
  });

  test('pick prioritizes new items', () {
    final list = ['a', 'b', 'c', 'd', 'e'];
    final seen = {'a', 'b'};

    final result = pick<String>(
      list,
      3,
      (s) => s,
      seen,
    );

    // It should return 3 items, with all new ones first
    expect(result.length, equals(3));
    expect(result, containsAll(['c', 'd', 'e']));
    expect(result.any((x) => seen.contains(x)), isFalse);
  });

  test('pick includes old ones if not enough new', () {
    final list = ['a', 'b', 'c'];
    final seen = {'a', 'b'};

    final result = pick<String>(
      list,
      2,
      (s) => s,
      seen,
    );

    expect(result.length, equals(2));
    expect(result, containsAll(['a', 'c']));
  });

  group('subset techniques', () {
    late Directory tempDir;
  
    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp('config_test');
      PathProviderPlatform.instance = _FakePathProvider(tempDir.path);
    });

    tearDownAll(() async {
      await tempDir.delete(recursive: true);
    });

    test('subsetTechniques returns correct number of techniques per position', () async {
      await ConfigService.loadConfig();
      ConfigService.setConfig('prioritizeBy', 'attack');
      ConfigService.setConfig('timePerTechnique', 70);
      ConfigService.saveConfig();

      final subset = await subsetTechniques(
        path: 'assets/technique/techniques.csv',
        grade: '4 Kyu',
        gradeTimeCsvPath: 'assets/technique/grade_time.csv',
      );

      expect(subset, isNotEmpty);

      // Example: 3 positions = tachi, suwari, hanmi → check distribution
      final tachi = subset.where((t) => t.position == 'Tachi waza');
      final suwari = subset.where((t) => t.position == 'Suwari waza');
      final hanmi = subset.where((t) => t.position == 'Hanmi Handachi waza');

      expect(tachi.length, 8);
      expect(suwari.length, 2);
      expect(hanmi.length, 0);
    });
  });
}