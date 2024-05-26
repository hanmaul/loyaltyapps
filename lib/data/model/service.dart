import 'package:isar/isar.dart';

part 'service.g.dart';

@collection
class Service {
  Id id = Isar.autoIncrement;
  String gambar;
  String judul;
  String keterangan;
  String link;

  Service(
      {required this.gambar,
      required this.judul,
      required this.keterangan,
      required this.link});
}
