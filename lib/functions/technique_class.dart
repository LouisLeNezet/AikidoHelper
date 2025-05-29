/// A single technique record.
class Technique {
  final String position;
  final String attack;
  final String technique;
  final String form;
  final String grade;

  Technique({
    required this.position,
    required this.attack,
    required this.technique,
    required this.form,
    required this.grade,
  });

  String operator [](String key) {
    switch (key) {
      case 'position':
        return position;
      case 'attack':
        return attack;
      case 'technique':
        return technique;
      case 'form':
        return form;
      case 'grade':
        return grade;
      default:
        throw ArgumentError('Invalid key: $key');
    }
  }

  // Override toString for custom printing
  @override
  String toString() {
    return '$position $attack $technique $form, grade: $grade)';
  }
}
