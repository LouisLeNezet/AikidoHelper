import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aikido_helper/functions/get_technique.dart';

class MockAssetBundle extends Mock implements AssetBundle {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAssetBundle mockAssetBundle;

  setUp(() {
    mockAssetBundle = MockAssetBundle();
  });

  group('getAllTechniques', () {
    test('should return a list of techniques for valid data', () async {
      const csvData = '''
Position\tAttack\tTechnique\tForm\tGrade
1\tAttack1\tTechnique1\tForm1\t5 Kyu
2\tAttack2\tTechnique2\tForm2\t4 Kyu
3\tAttack3\tTechnique3\tForm3\t3 Kyu
''';

      when(() => mockAssetBundle.loadString('assets/technique/technique.csv'))
          .thenAnswer((_) async => csvData);

      final result = await getAllTechniques(
        path: 'assets/technique/technique.csv',
        grade: '4 Kyu',
        bundle: mockAssetBundle,
      );

      expect(result, isA<List<List<String>>>());
      expect(result.length, 2);
    });

    test('should throw an exception when the CSV is empty', () async {
      when(() => mockAssetBundle.loadString('assets/technique/technique.csv'))
          .thenAnswer((_) async => '');

      expect(() async => await getAllTechniques(
        path: 'assets/technique/technique.csv',
        grade: '5 Kyu',
        bundle: mockAssetBundle,
      ),
          throwsA(isA<Exception>()));
    });

    test('should throw an exception for invalid grade', () async {
      const csvData = '''
Position\tAttack\tTechnique\tForm\tGrade
1\tAttack1\tTechnique1\tForm1\t5 Kyu
2\tAttack2\tTechnique2\tForm2\t4 Kyu
3\tAttack3\tTechnique3\tForm3\t3 Kyu
''';

      when(() => mockAssetBundle.loadString('assets/technique/technique.csv'))
          .thenAnswer((_) async => csvData);

      expect(() async => await getAllTechniques(
        path: 'assets/technique/technique.csv',
        grade: '10 Kyu',
        bundle: mockAssetBundle,
      ),
          throwsA(isA<Exception>()));
    });
  });
}
