import '../../functions/config_service.dart';

Future<String> getAppVersion() async {
  await ConfigService.loadConfig();
  final appVersion = ConfigService.getConfig('appVersion');
  return appVersion;
}