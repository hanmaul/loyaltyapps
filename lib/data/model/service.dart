class Service {
  final String gambar;
  final String judul;
  final String keterangan;
  final String link;

  Service({
    required this.gambar,
    required this.judul,
    required this.keterangan,
    required this.link,
  });

  factory Service.fromJson(Map<String, dynamic> map) {
    final gambar = map['mGambar'] == null ? '' : map['mGambar'] as String;
    final judul = map['mJudul'] == null ? '' : map['mJudul'] as String;
    final keterangan =
        map['mKeterangan'] == null ? '' : map['mKeterangan'] as String;
    final link = map['mLink'] == null ? '' : map['mLink'] as String;

    return Service(
      gambar: gambar,
      judul: judul,
      keterangan: keterangan,
      link: link,
    );
  }
}
