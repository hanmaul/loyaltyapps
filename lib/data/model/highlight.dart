import 'package:isar/isar.dart';

part 'highlight.g.dart';

@collection
class Highlight {
  Id id = Isar.autoIncrement;
  String gambar;
  String judul;
  String keterangan;
  String link;

  Highlight(
      {required this.gambar,
      required this.judul,
      required this.keterangan,
      required this.link});
}
