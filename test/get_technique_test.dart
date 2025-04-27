import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:aikido_helper/functions/exam_json.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class MockPathProviderPlatform extends PathProviderPlatform {
  final String mockPath;
  MockPathProviderPlatform(this.mockPath);

  @override
  Future<String> getApplicationDocumentsPath() async {
    return mockPath;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Exam JSON utilities', () {
    late Directory tempDir;
    late File examFile;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp('exam_test');
      PathProviderPlatform.instance = MockPathProviderPlatform(tempDir.path);
    });

    tearDownAll(() async {
      await tempDir.delete(recursive: true);
    });

    setUp(() async {
      // Create a fake exam file before each test
      final examJson = {
        'metadata': {
          'size': 2,
        },
        'evaluation': [
          {
            'index': 1,
            'position': 'Position1',
            'attack': 'Attack1',
            'technique': 'Technique1',
          },
          {
            'index': 2,
            'position': 'Position2',
            'attack': 'Attack2',
            'technique': 'Technique2',
          },
        ],
      };
      examFile = File('${tempDir.path}/exam.json');
      await examFile.writeAsString(jsonEncode(examJson), flush: true);
    });

    group('getExamJsonData', () {
      test('returns the correct technique when index exists', () async {
        final result = await getExamJsonData(fileName: 'exam');

        expect(result, isA<Map<String, dynamic>>());
        expect(result.containsKey('metadata'), isTrue);
        expect(result.containsKey('evaluation'), isTrue);
        
        // Check inside evaluation
        final evaluation = result['evaluation'] as List;
        final firstTechnique = evaluation.first as Map<String, dynamic>;

        expect(firstTechnique['position'], 'Position1');
        expect(firstTechnique['attack'], 'Attack1');
        expect(firstTechnique['technique'], 'Technique1');
      });

      test('throws exception if file does not exist', () async {
        await expectLater(
          () => getExamJsonData(fileName: 'nonexistent_file'),
          throwsException,
        );
      });

      test('throws exception if file missing evaluation section', () async {
        final badFile = File('${tempDir.path}/bad_exam.json');
        await badFile.writeAsString(jsonEncode({'metadata': {'size': 1}}));

        // File name is 'bad_exam' (without .json)
        await expectLater(
          () => getExamJsonData(fileName: 'bad_exam'),
          throwsException,
        );
      });
    });

    group('getTechniqueByIndex', () {
      test('returns the correct technique when index exists', () async {
        final result = await getTechniqueByIndex(fileName: "exam", index: 1);

        expect(result, isA<Map<String, dynamic>>());
        expect(result['position'], 'Position1');
        expect(result['attack'], 'Attack1');
      });

      test('throws if technique with index does not exist', () async {
        expect(
          () => getTechniqueByIndex(fileName: "exam", index: 999),
          throwsException,
        );
      });

      test('throws if "evaluation" section is missing', () async {
        final badFile = File('${tempDir.path}/bad_exam.json');
        await badFile.writeAsString(jsonEncode({'metadata': {'size': 1}}));

        expect(
          () => getTechniqueByIndex(fileName: "bad_exam", index: 1),
          throwsException,
        );
      });
    });

    group('getExamMetadataKey', () {
      test('returns the correct exam size', () async {
        final size = await getExamMetadataKey<int>(fileName: "exam", key: 'size');
        expect(size, 2);
      });

      test('throws if metadata is missing', () async {
        final badFile = File('${tempDir.path}/bad_metadata_exam.json');
        await badFile.writeAsString(jsonEncode({'evaluation': []}));

        expect(
          () => getExamMetadataKey<int>(fileName: "bad_metadata_exam", key: 'size'),
          throwsException,
        );
      });

      test('throws if size field is missing or invalid', () async {
        final badFile = File('${tempDir.path}/bad_size_exam.json');
        await badFile.writeAsString(jsonEncode({'metadata': {}}));

        expect(
          () => getExamMetadataKey<int>(fileName: "bad_size_exam", key: 'size'),
          throwsException,
        );
      });
    });

    group('getTechniqueAndExamSize', () {
      test('returns technique and size successfully', () async {
        final result = await getTechniqueAndExamSize(fileName: "exam", index: 1);

        expect(result, isA<Map<String, dynamic>>());
        expect(result['technique'], isA<Map<String, dynamic>>());
        expect(result['technique']['position'], 'Position1');
        expect(result['technique']['attack'], 'Attack1');
        expect(result['size'], 2);
      });

      test('throws if technique by index is not found', () async {
        expect(
          () => getTechniqueAndExamSize(fileName: "exam", index: 999),
          throwsException,
        );
      });

      test('throws if metadata is missing', () async {
        final badFile = File('${tempDir.path}/bad_metadata_exam.json');
        await badFile.writeAsString(jsonEncode({'evaluation': []}));

        expect(
          () => getTechniqueAndExamSize(fileName: "bad_metadata_exam", index: 1),
          throwsException,
        );
      });

      test('throws if size field is missing or invalid', () async {
        final badFile = File('${tempDir.path}/bad_size_exam.json');
        await badFile.writeAsString(jsonEncode({'metadata': {}}));

        expect(
          () => getTechniqueAndExamSize(fileName: "bad_size_exam", index: 1),
          throwsException,
        );
      });
    });
  });
}
