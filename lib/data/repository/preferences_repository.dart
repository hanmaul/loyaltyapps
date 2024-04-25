import 'package:shared_preferences/shared_preferences.dart';

class PrefRepository {
  // Future<void> removeSession() async {
  //   SharedPreferences pref = await SharedPreferences.getInstance();
  //   await pref.clear();
  // }

  Future<void> removeSession({required List<String> excludeKeys}) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    Set<String> keys = pref.getKeys();

    for (String key in keys) {
      if (!excludeKeys.contains(key)) {
        await pref.remove(key);
      }
    }
  }

  Future<bool?> firstAccess() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getBool('firstAccess');
  }

  Future<void> firstAccessFalse() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setBool("firstAccess", true);
  }

  Future<void> setNomor(String nomor) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString("nomor", nomor);
  }

  Future<String> getNomor() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString("nomor") ?? "";
  }

  Future<void> setKey(String key) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString("key", key);
  }

  Future<String> getKey() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString("key") ?? "";
  }

  Future<void> setName(String nama) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString("nama", nama);
  }

  Future<String> getName() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString("nama") ?? "";
  }

  Future<void> setCustId(String custId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString("cust_id", custId);
  }

  Future<String> getCustId() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString("cust_id") ?? "";
  }

  Future<void> setStatus(String status) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString("status", status);
  }

  Future<String> getStatus() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString("status") ?? "";
  }

  Future<void> setFtoken(String token) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString("firebaseToken", token);
  }

  Future<String> getFtoken() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString("firebaseToken") ?? "";
  }
}
