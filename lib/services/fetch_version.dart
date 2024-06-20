import 'package:loyalty/data/repository/database_repository.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersion {
  Future<void> getVersion() async {
    final info = await PackageInfo.fromPlatform();

    // save version to storage
    await DatabaseRepository()
        .updateUser(field: 'appVersion', data: info.version);
  }
}
