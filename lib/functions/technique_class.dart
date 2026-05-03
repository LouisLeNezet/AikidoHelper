/// A single technique record.
class Technique {
  final String waza;
  final String attack;
  final String technique;
  final String form;
  final String grade;
  final List<String> links;
  final String markdown;
  final List<Map<String, dynamic>> progression;

  Technique({
    required this.waza,
    required this.attack,
    required this.technique,
    required this.form,
    required this.grade,
    this.links = const [],
    this.markdown = '',
    this.progression = const [],
  });

  dynamic operator [](String key) {
    switch (key) {
      case 'waza':
        return waza;
      case 'attack':
        return attack;
      case 'technique':
        return technique;
      case 'form':
        return form;
      case 'grade':
        return grade;
      case 'links':
        return links;
      case 'markdown':
        return markdown;
      case 'progression':
        return progression;
      default:
        throw ArgumentError('Invalid key: $key');
    }
  }

  // Override toString for custom printing
  @override
  String toString() {
    return '$waza $attack $technique $form, grade: $grade)';
  }
}
