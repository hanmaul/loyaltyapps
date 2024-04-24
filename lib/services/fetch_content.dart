import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:loyalty/data/repository/preferences_repository.dart';

class DataContent {
  Future<http.Response> getContents() async {
    String custId = await PrefRepository().getCustId();
    String fToken = await PrefRepository().getFtoken();

    const baseUrl =
        "https://www.kamm-group.com:8070/fapi/newcontent2?key=3356271533a91b348974492cba3b7d6c";
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'Cust_id': custId,
        'FCM': fToken,
      }),
    );
    return response;
  }
}
