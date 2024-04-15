import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:loyalty/screen/dashboard.dart';
import 'package:loyalty/screen/webview/register.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class sendOtp extends StatefulWidget {
  const sendOtp({super.key});

  @override
  State<sendOtp> createState() => _sendOtpState();
}

class _sendOtpState extends State<sendOtp> {
  String nomor = "";

  void getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      nomor = pref.getString("nomor")!;
    });
  }

  void sendOTP(String otp) async {
    try {
      final response = await http.post(
        Uri.parse(
            "https://www.kamm-group.com:8070/loyaltykammapi_native/public/index.php/verifyotphp"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'nohp': nomor,
          'otpcode': otp,
        }),
      );

      List<dynamic> output = jsonDecode(response.body);
      Map<String, dynamic> result = output[0];

      if (response.statusCode == 200) {
        saveSession(result['nama'], result['Cust_id'],
            result['status_mediator'], result['key']);
      } else {
        throw Exception('Failed to generate OTP');
      }
    } catch (e) {
      debugPrint('$e');
    }
  }

  Future<void> saveSession(String nama, cust_id, status, key) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString("nama", nama);
    await pref.setString("cust_id", cust_id);
    await pref.setString("status", status);
    await pref.setString("key", key);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          if (nama != "") {
            return Dashboard();
          } else {
            return Register();
          }
        },
      ),
      (route) => false,
    );
  }

  void generateOTP() async {
    final response = await http.post(
      Uri.parse('https://www.kamm-group.com:8070/fapi/autocust'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'nohp': nomor,
      }),
    );
    if (response.statusCode == 200) {
      debugPrint('OTP Berhasil Dikirim');
    } else {
      throw Exception('Failed to generate OTP');
    }
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    final pinputTheme = PinTheme(
      width: 38,
      height: 46,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Colors.black,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.transparent),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        // title: Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     //SquareTile(imagePath: 'lib/assets/images/logo.png'),
        //     // const Text("Welcome"),
        //   ],
        // ),
        leading: GestureDetector(
          child: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: Colors.white,
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: const Color(0xff0B60B0),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        color: const Color(0xff0B60B0),
        child: Center(
          child: Column(
            children: [
              const Text(
                'Verifikasi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 26),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                  ),
                  children: <TextSpan>[
                    TextSpan(text: 'Masukkan '),
                    TextSpan(
                      text: 'Kode OTP',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    TextSpan(text: ' yang sudah dikirim ke '),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                nomor,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 46),
              Pinput(
                autofocus: true,
                length: 6,
                defaultPinTheme: pinputTheme,
                focusedPinTheme: pinputTheme.copyWith(
                  decoration: pinputTheme.decoration!.copyWith(
                    border: Border.all(color: const Color(0xff8F3232)),
                  ),
                ),
                onCompleted: (otp) => sendOTP(otp),
              ),
              const SizedBox(height: 46),
              const Text(
                'Tidak menerima kode?',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  generateOTP();
                },
                child: const Text(
                  'Kirim ulang',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white60,
                    color: Colors.white60,
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
