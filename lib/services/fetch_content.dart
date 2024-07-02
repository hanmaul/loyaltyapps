import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:loyalty/data/repository/database_repository.dart';

class DataContent {
  Future<http.Response> getContents() async {
    String custId = await DatabaseRepository().loadUser(field: 'custId');
    String fToken = await DatabaseRepository().loadUser(field: 'firebaseToken');
    String platform = await checkPlatform();

    const baseUrl =
        "https://kamm-group.com:8070/fapi/newcontent2?key=3356271533a91b348974492cba3b7d6c";
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'Cust_id': custId,
        'FCM': fToken,
        'Platform': platform,
      }),
    );
    return response;
  }

  Future<String> checkPlatform() async {
    if (Platform.isIOS) {
      return "IOS";
    } else if (Platform.isAndroid) {
      return "ANDROID";
    } else {
      return "OTHER";
    }
  }

  Future<http.Response> getNotifUnread() async {
    String custId = await DatabaseRepository().loadUser(field: 'custId');

    const baseUrl = "https://kamm-group.com:8070/notif_loyalty/api/unread";
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'cust_id': custId,
      }),
    );
    return response;
  }
}
