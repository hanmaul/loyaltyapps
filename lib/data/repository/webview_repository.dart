import 'package:loyalty/data/repository/preferences_repository.dart';

class WebviewRepository {
  Future<String> getUrlAkunku() async {
    String key = await PrefRepository().getKey();
    String url =
        "http://mobilekamm.ddns.net:8065/m_mlp/mobile/akun/profile?key=";
    String urlAkunku = url + key;
    return urlAkunku;
  }

  Future<String> getUrlRegister() async {
    String key = await PrefRepository().getKey();
    String url =
        "http://mobilekamm.ddns.net:8065/m_mlp/mobile/akun/registrasi/data-diri?key=";
    String urlRegister = url + key;
    return urlRegister;
  }
}
