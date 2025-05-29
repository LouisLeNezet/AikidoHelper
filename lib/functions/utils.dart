import '../../functions/config_service.dart';

Future<String> getAppVersion() async {
  await ConfigService.loadConfig();
  final appVersion = ConfigService.getConfig('appVersion');
  return appVersion;
}

String toTitleCase(String input) {
  if (input.isEmpty) return input;
  return input.split(' ').map((word) {
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}
