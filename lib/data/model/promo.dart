import 'package:isar/isar.dart';

part 'promo.g.dart';

@collection
class Promo {
  Id id = Isar.autoIncrement;
  String gambar;
  String judul;
  String keterangan;
  String link;

  Promo(
      {required this.gambar,
      required this.judul,
      required this.keterangan,
      required this.link});
}
