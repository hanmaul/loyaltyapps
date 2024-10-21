import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:loyalty/data/model/banner.dart';
import 'package:loyalty/data/model/highlight.dart';
import 'package:loyalty/data/model/logged_out.dart';
import 'package:loyalty/data/model/promo.dart';
import 'package:loyalty/data/model/service.dart';
import 'package:loyalty/data/model/user.dart';
import 'package:loyalty/services/fetch_content.dart';
import 'package:loyalty/services/fetch_version.dart';
import 'package:loyalty/services/firebase_api.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseRepository {
  static final DatabaseRepository _instance = DatabaseRepository._internal();

  // Factory constructor to return the singleton instance
  factory DatabaseRepository() {
    return _instance;
  }

  // Private constructor for internal singleton usage
  DatabaseRepository._internal();

  // Step 2: Store the Isar instance here
  static Isar? _isarInstance;

  // Step 3: Method to open the Isar database only once
  Future<Isar> openDatabase() async {
    if (_isarInstance == null) {
      // Open the Isar instance if not already open
      final dir = await getApplicationDocumentsDirectory();
      _isarInstance = await Isar.open([
        UserSchema,
        ServiceSchema,
        HighlightSchema,
        PromoSchema,
        BannerSchema,
        LoggedOutSchema,
      ], directory: dir.path);
    }
    return _isarInstance!;
  }

  Future<bool> checkUserExists() async {
    final Isar dbInstance = await openDatabase();
    final existingUser = await dbInstance.users.get(1);
    return existingUser != null;
  }

  Future<void> saveUser({
    required Map<String, dynamic> userData,
    required bool newDevice,
    required bool forceLogout,
  }) async {
    // Data from Device
    FirebaseApi firebase = FirebaseApi();
    String fcmToken = await firebase.fetchFCM();
    String appVersion = await AppVersion().getVersion();

    String key = userData['key'];
    String custId = userData['Cust_id'];
    String nama = userData['nama'];
    String statusMediator = userData['status_mediator'];

    // Validate Token
    bool validToken = await firebase.validateToken(
        key: key, custId: custId, forceLogout: forceLogout);

    if (validToken || newDevice) {
      final Isar dbInstance = await openDatabase();
      final existingUser = await dbInstance.users.get(1);
      bool isRegistered = nama.isNotEmpty;

      if (existingUser != null) {
        existingUser.nama = nama;
        existingUser.custId = custId;
        existingUser.status = statusMediator;
        existingUser.key = key;
        existingUser.firebaseToken = fcmToken;
        existingUser.appVersion = appVersion;
        existingUser.registered = isRegistered;

        await dbInstance.writeTxn(() async {
          await dbInstance.users.put(existingUser);
        });
      } else {
        final newUser = User()
          ..id = 1
          ..nama = nama
          ..custId = custId
          ..status = statusMediator
          ..key = key
          ..firebaseToken = fcmToken
          ..appVersion = appVersion
          ..registered = isRegistered;

        await dbInstance.writeTxn(() async {
          await dbInstance.users.put(newUser);
        });
      }
    } else {
      return;
    }
  }

  Future<bool> isRegistered() async {
    final Isar dbInstance = await openDatabase();
    final existingUser = await dbInstance.users.get(1);

    if (existingUser != null) {
      return existingUser.registered;
    } else {
      return false;
    }
  }

  Future<void> registered() async {
    final Isar dbInstance = await openDatabase();
    final existingUser = await dbInstance.users.get(1);

    if (existingUser != null) {
      existingUser.registered = true;
      await dbInstance.writeTxn(() async {
        await dbInstance.users.put(existingUser);
      });
    }
  }

  // Save logout session data
  Future<void> saveLogoutSession(String reason) async {
    final Isar dbInstance = await openDatabase();
    final logoutSession = LoggedOut()
      ..reason = reason
      ..timestamp = DateTime.now();

    await dbInstance.writeTxn(() async {
      await dbInstance.loggedOuts.put(logoutSession);
    });
  }

  // Retrieve logout session
  Future<LoggedOut?> getLogoutSession() async {
    final Isar dbInstance = await openDatabase();
    return await dbInstance.loggedOuts.where().findFirst();
  }

  // Clear the logout session after the user acknowledges it
  Future<void> clearLogoutSession() async {
    final Isar dbInstance = await openDatabase();
    await dbInstance.writeTxn(() async {
      await dbInstance.loggedOuts.clear();
    });
  }

  Future<String> loadUser({required String field}) async {
    final Isar dbInstance = await openDatabase();
    final existingUser = await dbInstance.users.get(1);

    if (existingUser != null) {
      switch (field) {
        case 'nomor':
          return existingUser.nomor;
        case 'key':
          return existingUser.key;
        case 'nama':
          return existingUser.nama;
        case 'custId':
          return existingUser.custId;
        case 'status':
          return existingUser.status;
        case 'firebaseToken':
          return existingUser.firebaseToken;
        case 'firstAccess':
          return existingUser.firstAccess;
        case 'appVersion':
          return existingUser.appVersion;
        default:
          return '';
      }
    } else {
      return '';
    }
  }

  Future<void> updateUser({required String field, required String data}) async {
    final Isar dbInstance = await openDatabase();
    final existingUser = await dbInstance.users.get(1);

    if (existingUser != null) {
      switch (field) {
        case 'nomor':
          existingUser.nomor = data;
          break;
        case 'key':
          existingUser.key = data;
          break;
        case 'nama':
          existingUser.nama = data;
          break;
        case 'custId':
          existingUser.custId = data;
          break;
        case 'status':
          existingUser.status = data;
          break;
        case 'firebaseToken':
          existingUser.firebaseToken = data;
          break;
        case 'firstAccess':
          existingUser.firstAccess = data;
          break;
        case 'appVersion':
          existingUser.appVersion = data;
          break;
        default:
          return;
      }

      await dbInstance.writeTxn(() => dbInstance.users.put(existingUser));
    } else {
      final newUser = User();

      switch (field) {
        case 'nomor':
          newUser.nomor = data;
          break;
        case 'key':
          newUser.key = data;
          break;
        case 'nama':
          newUser.nama = data;
          break;
        case 'custId':
          newUser.custId = data;
          break;
        case 'status':
          newUser.status = data;
          break;
        case 'firebaseToken':
          newUser.firebaseToken = data;
          break;
        case 'firstAccess':
          newUser.firstAccess = data;
          break;
        case 'appVersion':
          newUser.appVersion = data;
          break;
        default:
          return;
      }
      await dbInstance.writeTxn(() => dbInstance.users.put(newUser));
    }
  }

  // Fetching data from API (For pull-to-refresh or first load if no data is present)

  Future<List<Service>> fetchServicesFromApi() async {
    final response = await DataContent().getContents();
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      List<dynamic> data = json['menu1'];
      return data
          .map((item) => Service(
                gambar: item['mGambar'] ?? '',
                judul: item['mJudul'] ?? '',
                keterangan: item['mKeterangan'] ?? '',
                link: item['mLink'] ?? '',
              ))
          .toList();
    } else {
      throw Exception('Failed to fetch services from API');
    }
  }

  Future<List<Highlight>> fetchHighlightsFromApi() async {
    final response = await DataContent().getContents();
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      List<dynamic> data = json['menuheader'];
      return data
          .map((item) => Highlight(
                gambar: item['mGambar'] ?? '',
                judul: item['mJudul'] ?? '',
                keterangan: item['nominal'] ?? '0',
                link: item['mLink'] ?? '',
              ))
          .toList();
    } else {
      throw Exception('Failed to fetch highlights from API');
    }
  }

  Future<List<Promo>> fetchPromosFromApi() async {
    final response = await DataContent().getContents();
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      List<dynamic> data = json['menulist'];
      return data
          .map((item) => Promo(
                gambar: item['mGambar'] ?? '',
                judul: item['mJudul'] ?? '',
                keterangan: item['mKeterangan'] ?? '',
                link: item['mLink'] ?? '',
              ))
          .toList();
    } else {
      throw Exception('Failed to fetch promos from API');
    }
  }

  Future<List<Banner>> fetchBannersFromApi() async {
    final response = await DataContent().getContents();
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      List<dynamic> data = json['banner'];
      return data.map((item) => Banner(gambar: item)).toList();
    } else {
      throw Exception('Failed to fetch banners from API');
    }
  }

  // Save methods to store API-fetched data to local storage
  Future<void> saveServices(List<Service> services) async {
    final Isar dbInstance = await openDatabase();
    await dbInstance.writeTxn(() async {
      for (var service in services) {
        await dbInstance.services.put(service);
      }
    });
  }

  Future<void> saveHighlights(List<Highlight> highlights) async {
    final Isar dbInstance = await openDatabase();
    await dbInstance.writeTxn(() async {
      for (var highlight in highlights) {
        await dbInstance.highlights.put(highlight);
      }
    });
  }

  Future<void> savePromos(List<Promo> promos) async {
    final Isar dbInstance = await openDatabase();
    await dbInstance.writeTxn(() async {
      for (var promo in promos) {
        await dbInstance.promos.put(promo);
      }
    });
  }

  Future<void> saveBanners(List<Banner> banners) async {
    final Isar dbInstance = await openDatabase();
    await dbInstance.writeTxn(() async {
      for (var banner in banners) {
        await dbInstance.banners.put(banner);
      }
    });
  }

  // Load methods to retrieve data from local storage

  Future<List<Service>> loadAllService() async {
    final Isar dbInstance = await openDatabase();
    return await dbInstance.services.where().findAll();
  }

  Future<List<Highlight>> loadAllHighlight() async {
    final Isar dbInstance = await openDatabase();
    return await dbInstance.highlights.where().findAll();
  }

  Future<List<Promo>> loadAllPromo() async {
    final Isar dbInstance = await openDatabase();
    return await dbInstance.promos.where().findAll();
  }

  Future<List<Banner>> loadAllBanner() async {
    final Isar dbInstance = await openDatabase();
    return await dbInstance.banners.where().findAll();
  }

  Future<void> clearDatabase() async {
    final Isar dbInstance = await openDatabase();
    await dbInstance.writeTxn(() async {
      await dbInstance.users.clear();
      await dbInstance.services.clear();
      await dbInstance.highlights.clear();
      await dbInstance.promos.clear();
      await dbInstance.banners.clear();
    });
  }

  Future<void> clearContent() async {
    final Isar dbInstance = await openDatabase();
    await dbInstance.writeTxn(() async {
      await dbInstance.services.clear();
      await dbInstance.highlights.clear();
      await dbInstance.promos.clear();
      await dbInstance.banners.clear();
    });
  }
}
