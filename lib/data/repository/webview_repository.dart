import 'package:loyalty/data/repository/database_repository.dart';

class WebviewRepository {
  Future<String> getUrlAkunku() async {
    String key = await DatabaseRepository().loadUser(field: "key");
    String url =
        "http://mobilekamm.ddns.net:8065/m_mlp/mobile/akun/profile?key=";
    String urlAkunku = url + key;
    return urlAkunku;
  }

  Future<String> getUrlRegister() async {
    String key = await DatabaseRepository().loadUser(field: "key");
    String url =
        "http://mobilekamm.ddns.net:8065/m_mlp/mobile/akun/registrasi/data-diri?key=";
    String urlRegister = url + key;
    return urlRegister;
  }

  Future<String> getUrlHistory() async {
    String custId = await DatabaseRepository().loadUser(field: "custId");
    String url = "http://mobilekamm.ddns.net:8065/mls/mobile/kp/";
    String urlHistory = url + custId;
    return urlHistory;
  }

  Future<String> getUrlNotifikasi() async {
    String custId = await DatabaseRepository().loadUser(field: "custId");
    String url = "http://mobilekamm.ddns.net:8065/notif_loyalty/get/";
    String urlNotifikasi = url + custId;
    return urlNotifikasi;
  }
}
