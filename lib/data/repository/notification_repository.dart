import 'dart:convert';

import 'package:loyalty/services/fetch_content.dart';

class NotifRepository {
  Future<int> getUnread() async {
    DataContent dataContent = DataContent();
    final response = await dataContent.getNotifUnread();
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return result['total'];
    } else {
      throw Exception('Failed to load data!');
    }
  }
}
