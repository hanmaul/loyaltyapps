class Highlight {
  final String gambar;
  final String judul;
  final String keterangan;
  final String link;

  Highlight({
    required this.gambar,
    required this.judul,
    required this.keterangan,
    required this.link,
  });

  static String? _savedGambar;
  static String? _savedJudul;
  static String? _savedKeterangan;
  static String? _savedLink;

  factory Highlight.fromJson(Map<String, dynamic> map) {
    _savedGambar = map['mGambar'] == null ? '' : map['mGambar'] as String;
    _savedJudul = map['mJudul'] == null ? '' : map['mJudul'] as String;
    _savedKeterangan =
        map['mKeterangan'] == null ? '' : map['mKeterangan'] as String;
    _savedLink = map['mLink'] == null ? '' : map['mLink'] as String;

    return Highlight(
      gambar: _savedGambar ?? '',
      judul: _savedJudul ?? '',
      keterangan: _savedKeterangan ?? '',
      link: _savedLink ?? '',
    );
  }

  static Highlight fromSaved() {
    return Highlight(
      gambar: _savedGambar ?? '',
      judul: _savedJudul ?? '',
      keterangan: _savedKeterangan ?? '',
      link: _savedLink ?? '',
    );
  }
}
