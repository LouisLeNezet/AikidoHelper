import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:aikido_helper/functions/exam_json.dart';

void main() {
  group('Exam JSON utilities', () {
    late Directory tempDir;
    late File examFile;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp('exam_test');
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
            'order': 1,
            'position': 'Position1',
            'attack': 'Attack1',
            'technique': 'Technique1',
          },
          {
            'order': 2,
            'position': 'Position2',
            'attack': 'Attack2',
            'technique': 'Technique2',
          },
        ],
      };
      examFile = File('${tempDir.path}/exam.json');
      await examFile.writeAsString(jsonEncode(examJson), flush: true);
    });

    group('getTechniqueByIndex', () {
      test('returns the correct technique when index exists', () async {
        final result = await getTechniqueByIndex(jsonFile: examFile, index: 1);

        expect(result, isA<Map<String, dynamic>>());
        expect(result['position'], 'Position1');
        expect(result['attack'], 'Attack1');
      });

      test('throws if technique with index does not exist', () async {
        expect(
          () => getTechniqueByIndex(jsonFile: examFile, index: 999),
          throwsException,
        );
      });

      test('throws if "evaluation" section is missing', () async {
        final badFile = File('${tempDir.path}/bad_exam.json');
        await badFile.writeAsString(jsonEncode({'metadata': {'size': 1}}));

        expect(
          () => getTechniqueByIndex(jsonFile: badFile, index: 1),
          throwsException,
        );
      });
    });

    group('getExamMetadataKey', () {
      test('returns the correct exam size', () async {
        final size = await getExamMetadataKey<int>(jsonFile: examFile, key: 'size');
        expect(size, 2);
      });

      test('throws if metadata is missing', () async {
        final badFile = File('${tempDir.path}/bad_metadata_exam.json');
        await badFile.writeAsString(jsonEncode({'evaluation': []}));

        expect(
          () => getExamMetadataKey<int>(jsonFile: badFile, key: 'size'),
          throwsException,
        );
      });

      test('throws if size field is missing or invalid', () async {
        final badFile = File('${tempDir.path}/bad_size_exam.json');
        await badFile.writeAsString(jsonEncode({'metadata': {}}));

        expect(
          () => getExamMetadataKey<int>(jsonFile: badFile, key: 'size'),
          throwsException,
        );
      });
    });

    group('getTechniqueAndExamSize', () {
      test('returns technique and size successfully', () async {
        final result = await getTechniqueAndExamSize(jsonFile: examFile, index: 1);

        expect(result, isA<Map<String, dynamic>>());
        expect(result['technique'], isA<Map<String, dynamic>>());
        expect(result['technique']['position'], 'Position1');
        expect(result['technique']['attack'], 'Attack1');
        expect(result['size'], 2);
      });

      test('throws if technique by index is not found', () async {
        expect(
          () => getTechniqueAndExamSize(jsonFile: examFile, index: 999),
          throwsException,
        );
      });

      test('throws if metadata is missing', () async {
        final badFile = File('${tempDir.path}/bad_metadata_exam.json');
        await badFile.writeAsString(jsonEncode({'evaluation': []}));

        expect(
          () => getTechniqueAndExamSize(jsonFile: badFile, index: 1),
          throwsException,
        );
      });

      test('throws if size field is missing or invalid', () async {
        final badFile = File('${tempDir.path}/bad_size_exam.json');
        await badFile.writeAsString(jsonEncode({'metadata': {}}));

        expect(
          () => getTechniqueAndExamSize(jsonFile: badFile, index: 1),
          throwsException,
        );
      });
    });
  });
}
