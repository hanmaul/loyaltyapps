import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:loyalty/data/repository/database_repository.dart';

class ManageOtp {
  Future<http.Response> getOtp(String nomor) async {
    final no = nomor[0] == "0" ? nomor : "0$nomor";
    const baseUrl = "https://www.kamm-group.com:8070/fapi/autocust";
    try {
      final response = await http
          .post(
            Uri.parse(baseUrl),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{
              'nohp': no,
            }),
          )
          .timeout(const Duration(seconds: 10));

      // Handle successful response
      if (response.statusCode == 200) {
        await DatabaseRepository().updateUser(field: 'nomor', data: no);
      }
      return response;
    } on TimeoutException catch (_) {
      throw Exception('Waktu permintaan habis. Silakan coba lagi.');
    } on http.ClientException catch (_) {
      throw Exception('Kesalahan jaringan. Silakan coba lagi.');
    } catch (e) {
      throw Exception('Terjadi kesalahan tak terduga.');
    }
  }

  Future<http.Response> reGetOtp() async {
    DatabaseRepository databaseRepository = DatabaseRepository();
    String nomor = await databaseRepository.loadUser(field: 'nomor');
    const baseUrl = "https://www.kamm-group.com:8070/fapi/autocust";

    try {
      final response = await http
          .post(
            Uri.parse(baseUrl),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{
              'nohp': nomor,
            }),
          )
          .timeout(const Duration(seconds: 10));

      return response;
    } on TimeoutException {
      throw Exception('Waktu permintaan habis. Silakan coba lagi.');
    } on http.ClientException {
      throw Exception('Kesalahan jaringan. Silakan coba lagi.');
    } catch (e) {
      throw Exception('Terjadi kesalahan tak terduga.');
    }
  }

  Future<Map<String, dynamic>> sendOtp(String otp) async {
    DatabaseRepository databaseRepository = DatabaseRepository();
    String nomor = await databaseRepository.loadUser(field: 'nomor');
    const baseUrl =
        "https://www.kamm-group.com:8070/loyaltykammapi_native/public/index.php/verifyotphp";

    try {
      final response = await http
          .post(
            Uri.parse(baseUrl),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{
              'nohp': nomor,
              'otpcode': otp,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 && response.body != 'otp salah') {
        List<dynamic> output = jsonDecode(response.body);
        Map<String, dynamic> userData = output[0];
        await databaseRepository.saveUser(
            userData: userData, newDevice: false, forceLogout: true);
        return userData;
      } else {
        return {'status': 'failed'};
      }
    } on TimeoutException {
      throw Exception('Waktu permintaan habis. Silakan coba lagi.');
    } on http.ClientException {
      throw Exception('Kesalahan jaringan. Silakan coba lagi.');
    } catch (e) {
      throw Exception('Terjadi kesalahan tak terduga.');
    }
  }
}
