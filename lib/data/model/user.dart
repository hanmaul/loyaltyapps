import 'package:isar/isar.dart';

part 'user.g.dart';

@Collection()
class User {
  Id id = Isar.autoIncrement;
  late String nomor = '';
  late String key = '';
  late String nama = '';
  late String custId = '';
  late String status = '';
  late String firebaseToken = '';
  late String firstAccess = '';
  late String appVersion = '';
  late bool registered = false;
}
