import 'package:isar/isar.dart';

part 'banner.g.dart';

@collection
class Banner {
  Id id = Isar.autoIncrement;
  String gambar;

  Banner({required this.gambar});
}
