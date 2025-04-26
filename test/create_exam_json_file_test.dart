import 'dart:convert';
import 'dart:io';

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

      // Act
      final file = await createExamJsonFile(
        grade: fakeGrade,
        examName: fakeExamName,
        getAppVersionFn: () async => fakeVersion,
        getOrderedTechniquesFn: ({required path, required grade}) async => [
          ['Position1', 'Attack1', 'Technique1', 'Form1', '4 Kyu'],
          ['Position2', 'Attack2', 'Technique2', 'Form2', '4 Kyu'],
        ],
      );

      // Assert
      final content = await file.readAsString();
      final decoded = jsonDecode(content);

      expect(decoded['metadata']['grade'], fakeGrade);
      expect(decoded['metadata']['examName'], fakeExamName);
      expect(decoded['metadata']['version'], fakeVersion);
      expect(decoded['metadata']['size'], 2);

      expect(decoded['evaluation'], isA<List>());
      expect(decoded['evaluation'].length, 2);
      expect(decoded['evaluation'][0]['position'], 'Position1');
      expect(decoded['evaluation'][1]['position'], 'Position2');

      expect(file.path.endsWith('My_Exam.json'), isTrue);
    });
  });
}
