import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:loyalty/data/repository/database_repository.dart';
import 'package:loyalty/services/firebase_api.dart';

class ManageOtp {
  Future<http.Response> getOtp(String nomor) async {
    final no = nomor[0] == "0" ? nomor : "0$nomor";
    const baseUrl = "https://www.kamm-group.com:8070/fapi/autocust";
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'nohp': no,
      }),
    );
    if (response.statusCode == 200) {
      await DatabaseRepository().updateUser(field: 'nomor', data: no);
    }
    return response;
  }

  Future<http.Response> reGetOtp() async {
    DatabaseRepository databaseRepository = DatabaseRepository();
    String nomor = await databaseRepository.loadUser(field: 'nomor');
    const baseUrl = "https://www.kamm-group.com:8070/fapi/autocust";
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'nohp': nomor,
      }),
    );
    return response;
  }

  Future<http.Response> sendOtp(String otp) async {
    DatabaseRepository databaseRepository = DatabaseRepository();
    String nomor = await databaseRepository.loadUser(field: 'nomor');
    const baseUrl =
        "https://www.kamm-group.com:8070/loyaltykammapi_native/public/index.php/verifyotphp";
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'nohp': nomor,
        'otpcode': otp,
      }),
    );

    if (response.body != 'otp salah') {
      List<dynamic> output = jsonDecode(response.body);
      Map<String, dynamic> result = output[0];
      await DatabaseRepository()
          .updateUser(field: 'nama', data: result['nama']);
      await DatabaseRepository()
          .updateUser(field: 'custId', data: result['Cust_id']);
      await DatabaseRepository()
          .updateUser(field: 'status', data: result['status_mediator']);
      await DatabaseRepository().updateUser(field: 'key', data: result['key']);
      await FirebaseApi().getFCM();
    }
    return response;
  }
}
