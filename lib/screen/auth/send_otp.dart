import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:loyalty/data/repository/preferences_repository.dart';
import 'package:loyalty/data/repository/webview_repository.dart';
import 'package:loyalty/screen/dashboard.dart';
import 'package:loyalty/screen/webview/register.dart';
import 'package:loyalty/services/fetch_otp.dart';
import 'package:pinput/pinput.dart';

class sendOtp extends StatefulWidget {
  const sendOtp({super.key});

  @override
  State<sendOtp> createState() => _sendOtpState();
}

class _sendOtpState extends State<sendOtp> {
  @override
  void initState() {
    super.initState();
  }

  void sendOTP(String otp) async {
    try {
      final manageOtp = ManageOtp();
      final response = await manageOtp.sendOtp(otp);

      if (response.body == 'otp salah') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kode OTP Salah!'),
          ),
        );
      } else {
        nextPage();
      }
    } catch (e) {
      debugPrint('$e');
    }
  }

  Future<void> nextPage() async {
    PrefRepository prefRepository = PrefRepository();
    String nama = await prefRepository.getName();
    String url = await WebviewRepository().getUrlRegister();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          if (nama != "") {
            return Dashboard();
          } else {
            return Register(url: url);
          }
        },
      ),
      (route) => false,
    );
  }

  void generateOTP() async {
    String nomor = await PrefRepository().getNomor();
    final manageOtp = ManageOtp();
    final response = await manageOtp.getOtp(nomor);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kode OTP dikirim ke WhatsApp Anda!'),
        ),
      );
    } else {
      throw Exception('Failed to generate OTP');
    }
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
              FutureBuilder<String>(
                future: PrefRepository().getNomor(),
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(); // or some other widget while waiting
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return Text(
                      snapshot.data!, // the phone number
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }
                },
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
