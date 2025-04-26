import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'package:aikido_helper/functions/get_technique.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Mock assets for tests
    const csvTechniqueData = '''
Position\tAttack\tTechnique\tForm\tGrade
Tachi waza\tShomen uchi\tIkkyo\tOmote\t5 Kyu
Tachi waza\tShomen uchi\tNikyo\tOmote\t4 Kyu
    ''';

    const csvOrderData = '''
Name\tType\tOrder
Tachi waza\tPosition\t1
Shomen uchi\tAttack\t1
Ikkyo\tTechnique\t1
Nikyo\tTechnique\t2
Omote\tForm\t1
    ''';

    TestAssetBundle testAssetBundle = TestAssetBundle({
      'assets/technique/technique.csv': csvTechniqueData,
      'assets/technique/technique_ordering.csv': csvOrderData,
    });

    // Override the rootBundle
    ServicesBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
      'flutter/assets',
      (message) async {
        final String key = utf8.decode(message!.buffer.asUint8List());
        final data = testAssetBundle.assets[key];
        if (data == null) {
          return null;
        }
        return ByteData.view(utf8.encode(data).buffer);
      },
    );
  });

  test('getTechniqueNameFromCSV returns correct technique for grade', () async {
    final result0 = await getTechniqueNameFromCSV(
      path: 'assets/technique/technique.csv',
      grade: '4 Kyu',
      index: 0,
    );

    expect(result0, [
      'Tachi waza',
      'Shomen uchi',
      'Ikkyo',
      'Omote',
      '5 Kyu',
      2, // total techniques
    ]);

    final result1 = await getTechniqueNameFromCSV(
      path: 'assets/technique/technique.csv',
      grade: '4 Kyu',
      index: 1,
    );

    expect(result1, [
      'Tachi waza',
      'Shomen uchi',
      'Nikyo',
      'Omote',
      '4 Kyu',
      2, // total techniques
    ]);
  });
}

// Helper mock class
class TestAssetBundle {
  final Map<String, String> assets;

  TestAssetBundle(this.assets);
}
