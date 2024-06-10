import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loyalty/data/repository/database_repository.dart';
import 'package:loyalty/data/repository/webview_repository.dart';
import 'package:loyalty/screen/dashboard.dart';
import 'package:loyalty/screen/webview/register.dart';
import 'package:loyalty/services/fetch_otp.dart';
import 'package:pinput/pinput.dart';
import 'package:loyalty/screen/response/no_internet_page.dart';
import 'package:loyalty/components/alert.dart';

class SendOtp extends StatefulWidget {
  const SendOtp({super.key});

  @override
  State<SendOtp> createState() => _SendOtpState();
}

class _SendOtpState extends State<SendOtp> {
  @override
  void initState() {
    super.initState();
  }

  void showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Future<void> sendOTP(String otp) async {
    try {
      final manageOtp = ManageOtp();

      // Show loading dialog
      showLoadingDialog();

      final response = await manageOtp.sendOtp(otp);

      // Dismiss loading dialog
      Navigator.pop(context);

      if (response.body == 'otp salah') {
        if (mounted) {
          showAlert(
            context: context,
            title: 'OTP Salah!',
            content: 'Silakan periksa OTP Anda dan coba lagi.',
            type: 'error',
          );
        }
      } else {
        nextPage();
      }
    } catch (e) {
      debugPrint('$e');
    }
  }

  Future<void> nextPage() async {
    DatabaseRepository databaseRepository = DatabaseRepository();
    String nama = await databaseRepository.loadUser(field: 'nama');
    String url = await WebviewRepository().getUrlRegister();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          if (nama != "") {
            return Dashboard(page: 0);
          } else {
            return Register(url: url);
          }
        },
      ),
      (route) => false,
    );
  }

  Future<void> reGenerateOTP() async {
    final manageOtp = ManageOtp();
    final response = await manageOtp.reGetOtp();
    if (response.statusCode == 200) {
      if (mounted) {
        showAlert(
          context: context,
          title: 'OTP Dikirim!',
          content: 'Silakan periksa OTP Anda dan coba lagi.',
          type: 'info',
        );
      }
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
    return InternetAwareWidget(
      child: Scaffold(
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
                  future: DatabaseRepository().loadUser(field: 'nomor'),
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
                    reGenerateOTP();
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
      ),
    );
  }
}
