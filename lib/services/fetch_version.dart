import 'package:package_info_plus/package_info_plus.dart';

class AppVersion {
  Future<String> getVersion() async {
    final info = await PackageInfo.fromPlatform();
    String appVersion = info.version;
    return appVersion;
  }
}
