import 'package:isar/isar.dart';

part 'logged_out.g.dart';

@collection
class LoggedOut {
  Id id = Isar.autoIncrement;
  late String reason;
  late DateTime timestamp;
}
