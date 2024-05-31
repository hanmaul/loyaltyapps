import 'package:shared_preferences/shared_preferences.dart';

class PrefRepository {
  Future<void> removeSession() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.clear();
  }

  Future<bool> firstAccess() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getBool('firstAccess') ?? true;
  }

  Future<void> firstAccessFalse() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setBool("firstAccess", false);
  }
}
