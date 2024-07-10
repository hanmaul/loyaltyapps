import 'dart:convert';
import 'package:http/http.dart' as http;

class TermsService {
  Future<Map<String, dynamic>> listTerms() async {
    const baseUrl =
        "https://www.kamm-group.com:8070/fapi/mlpterm?key=3356271533a91b348974492cba3b7d6cz9";
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      List<dynamic> output = jsonDecode(response.body);
      Map<String, dynamic> terms = output[0];
      return terms;
    } else {
      return {'term': 'failed'};
    }
  }

  Future<void> agreeTerms() async {
    const baseUrl =
        "https://www.kamm-group.com:8070/fapi/agreterm?key=3356271533a91b348974492cba3b7d6cz9";

    await http.post(
      Uri.parse(baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'status': 'agree',
      }),
    );
  }
}
