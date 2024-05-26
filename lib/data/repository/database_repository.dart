import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:loyalty/data/model/banner.dart';
import 'package:loyalty/data/model/highlight.dart';
import 'package:loyalty/data/model/promo.dart';
import 'package:loyalty/data/model/service.dart';
import 'package:loyalty/services/fetch_content.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseRepository {
  late Future<Isar> _db;

  DatabaseRepository() {
    _db = openDatabase();
  }

  Future<Isar> openDatabase() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      final isar = await Isar.open(
          [ServiceSchema, HighlightSchema, PromoSchema, BannerSchema],
          directory: dir.path);
      return isar;
    }
    return Future.value(Isar.getInstance());
  }

  // -- Service --
  Future<List<Service>> loadAllService() async {
    final Isar dbInstance = await _db;
    List<Service> services = await dbInstance.services.where().findAll();

    if (services.isEmpty) {
      // Fetch data from API
      final response = await DataContent().getContents();
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        List<dynamic> data = json['menu1'];
        services = data
            .map((item) => Service(
                  gambar: item['mGambar'] ?? '',
                  judul: item['mJudul'] ?? '',
                  keterangan: item['mKeterangan'] ?? '',
                  link: item['mLink'] ?? '',
                ))
            .toList();

        // Store data locally
        for (var service in services) {
          await createNewService(
            gambar: service.gambar,
            judul: service.judul,
            keterangan: service.keterangan,
            link: service.link,
          );
        }
      } else {
        throw Exception('Failed to load Service from API');
      }
    }
    return services;
  }

  Future<void> createNewService(
      {required String gambar,
      required String judul,
      required String keterangan,
      required String link}) async {
    final Isar dbInstance = await _db;
    final service = Service(
        gambar: gambar, judul: judul, keterangan: keterangan, link: link);
    await dbInstance.writeTxn(() async {
      await dbInstance.services.put(service);
    });
  }
  // -- End of Service --

  // -- Highlight --
  Future<List<Highlight>> loadAllHighlight() async {
    final Isar dbInstance = await _db;
    List<Highlight> highlights = await dbInstance.highlights.where().findAll();

    if (highlights.isEmpty) {
      // Fetch data from API
      final response = await DataContent().getContents();
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        List<dynamic> data = json['menuheader'];
        highlights = data
            .map((item) => Highlight(
                  gambar: item['mGambar'] ?? '',
                  judul: item['mJudul'] ?? '',
                  keterangan: item['mKeterangan'] ?? '',
                  link: item['mLink'] ?? '',
                ))
            .toList();

        // Store data locally
        for (var highlight in highlights) {
          await createNewHighlight(
            gambar: highlight.gambar,
            judul: highlight.judul,
            keterangan: highlight.keterangan,
            link: highlight.link,
          );
        }
      } else {
        throw Exception('Failed to load Highlight from API');
      }
    }
    return highlights;
  }

  Future<void> createNewHighlight(
      {required String gambar,
      required String judul,
      required String keterangan,
      required String link}) async {
    final Isar dbInstance = await _db;
    final highlight = Highlight(
        gambar: gambar, judul: judul, keterangan: keterangan, link: link);
    await dbInstance.writeTxn(() async {
      await dbInstance.highlights.put(highlight);
    });
  }
  // -- End of Highlight --

// -- Promo --
  Future<List<Promo>> loadAllPromo() async {
    final Isar dbInstance = await _db;
    List<Promo> promos = await dbInstance.promos.where().findAll();

    if (promos.isEmpty) {
      // Fetch data from API
      final response = await DataContent().getContents();
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        List<dynamic> data = json['menulist'];
        promos = data
            .map((item) => Promo(
                  gambar: item['mGambar'] ?? '',
                  judul: item['mJudul'] ?? '',
                  keterangan: item['mKeterangan'] ?? '',
                  link: item['mLink'] ?? '',
                ))
            .toList();

        // Store data locally
        for (var promo in promos) {
          await createNewPromo(
            gambar: promo.gambar,
            judul: promo.judul,
            keterangan: promo.keterangan,
            link: promo.link,
          );
        }
      } else {
        throw Exception('Failed to load Promo from API');
      }
    }
    return promos;
  }

  Future<void> createNewPromo(
      {required String gambar,
      required String judul,
      required String keterangan,
      required String link}) async {
    final Isar dbInstance = await _db;
    final promo =
        Promo(gambar: gambar, judul: judul, keterangan: keterangan, link: link);
    await dbInstance.writeTxn(() async {
      await dbInstance.promos.put(promo);
    });
  }
  // -- End of Promo --

// -- Banner --
  Future<List<Banner>> loadAllBanner() async {
    final Isar dbInstance = await _db;
    List<Banner> banners = await dbInstance.banners.where().findAll();

    if (banners.isEmpty) {
      // Fetch data from API
      final response = await DataContent().getContents();
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        List<dynamic> data = json['banner'];
        banners = data
            .map((item) => Banner(
                  gambar: item,
                ))
            .toList();

        // Store data locally
        for (var banner in banners) {
          await createNewBanner(
            gambar: banner.gambar,
          );
        }
      } else {
        throw Exception('Failed to load Banner from API');
      }
    }
    return banners;
  }

  Future<void> createNewBanner({required String gambar}) async {
    final Isar dbInstance = await _db;
    final banner = Banner(gambar: gambar);
    await dbInstance.writeTxn(() async {
      await dbInstance.banners.put(banner);
    });
  }
  // -- End of Banner --

  Future<void> clearDatabase() async {
    final Isar dbInstance = await _db;
    await dbInstance.writeTxn(() async {
      await dbInstance.clear();
    });
  }
}
