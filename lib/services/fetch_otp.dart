import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:loyalty/data/repository/preferences_repository.dart';

class ManageOtp {
  Future<http.Response> getOtp(String nomor) async {
    final no = '0$nomor';
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
      await PrefRepository().setNomor(no);
    }
    return response;
  }

  Future<http.Response> sendOtp(String otp) async {
    PrefRepository prefRepository = PrefRepository();
    String nomor = await prefRepository.getNomor();
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
      await prefRepository.setName(result['nama']);
      await prefRepository.setCustId(result['Cust_id']);
      await prefRepository.setStatus(result['status_mediator']);
      await prefRepository.setKey(result['key']);
    }
    return response;
  }
}
