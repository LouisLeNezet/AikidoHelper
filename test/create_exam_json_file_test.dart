import 'dart:io';
import 'package:aikido_helper/functions/technique_class.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:aikido_helper/functions/exam_json.dart';

// --- Fake path_provider ---
class _FakePathProvider extends PathProviderPlatform {
  final String path;
  _FakePathProvider(this.path);

  @override
  Future<String?> getApplicationDocumentsPath() async => path;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('exam_test');
    PathProviderPlatform.instance = _FakePathProvider(tempDir.path);
  });

  tearDownAll(() async {
    await tempDir.delete(recursive: true);
  });

  group('createExamJsonFile', () {
    test('creates a JSON file with correct content', () async {
      // Arrange
      const fakeGrade = '4 Kyu';
      const fakeExamName = 'My Exam';
      const fakeVersion = '1.0.0';
      
      final technique1 = Technique(
        position: 'Position1',
        attack: 'Attack1',
        technique: 'Technique1',
        form: 'Form1',
        grade: fakeGrade,
      );
      final technique2 = Technique(
        position: 'Position2',
        attack: 'Attack2',
        technique: 'Technique2',
        form: 'Form2',
        grade: fakeGrade,
      );

      // Act
      final fileName = await createExamJsonFile(
        grade: fakeGrade,
        examName: fakeExamName,
        getAppVersionFn: () async => fakeVersion,
        subsetTechniquesFn: ({required path, required grade, required gradeTimeCsvPath}) async => [
          technique1,
          technique2,
        ],
      );

      // Assert
      final decoded = await getExamJsonData(fileName: fileName);

      expect(decoded['metadata']['grade'], fakeGrade);
      expect(decoded['metadata']['examName'], fakeExamName);
      expect(decoded['metadata']['version'], fakeVersion);
      expect(decoded['metadata']['size']['total'], 2);

      expect(decoded['evaluation'], isA<List>());
      expect(decoded['evaluation'].length, 2);
      expect(decoded['evaluation'][0]['position'], 'Position1');
      expect(decoded['evaluation'][1]['position'], 'Position2');
      expect(decoded['evaluation'][1]['duration'], 60);

      expect(fileName.endsWith('_My_Exam'), isTrue);
    });
  });
}
