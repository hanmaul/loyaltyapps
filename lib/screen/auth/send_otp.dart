import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loyalty/data/repository/database_repository.dart';
import 'package:loyalty/screen/dashboard/dashboard.dart';
import 'package:loyalty/screen/terms_of_use.dart';
import 'package:loyalty/screen/webview/register.dart';
import 'package:loyalty/services/fetch_otp.dart';
import 'package:pinput/pinput.dart';
import 'package:loyalty/screen/response/no_internet_page.dart';
import 'package:loyalty/components/alert.dart';

class SendOtp extends StatefulWidget {
  final String phoneNumber;
  const SendOtp({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<SendOtp> createState() => _SendOtpState();
}

class _SendOtpState extends State<SendOtp> {
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

      Map<String, dynamic> result = await manageOtp.sendOtp(otp);

      // Dismiss loading dialog
      Navigator.pop(context);

      if (result['status'] == 'failed') {
        if (mounted) {
          showAlert(
            context: context,
            title: 'OTP Salah!',
            content: 'Silakan periksa OTP Anda dan coba lagi.',
            type: 'error',
          );
        }
      } else {
        DatabaseRepository databaseRepository = DatabaseRepository();
        String keyExist = await databaseRepository.loadUser(field: "key");
        if (keyExist != '') {
          nextPage();
        } else {
          openTermsOfUse(data: result);
        }
      }
    } catch (e) {
      debugPrint('$e');
    }
  }

  Future<void> nextPage() async {
    DatabaseRepository databaseRepository = DatabaseRepository();
    String nama = await databaseRepository.loadUser(field: 'nama');
    if (nama != "") {
      goToDashboard();
    } else {
      goToRegister();
    }
  }

  Future<void> openTermsOfUse({required Map<String, dynamic> data}) async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return TermsOfUse(data: data);
        },
      ),
      (route) => false,
    );
  }

  void goToDashboard() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return const Dashboard(page: 0);
        },
      ),
      (route) => false,
    );
  }

  void goToRegister() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return const Register();
        },
      ),
      (route) => false,
    );
  }

  Future<void> reGenerateOTP() async {
    final manageOtp = ManageOtp();

    // Show loading dialog
    showLoadingDialog();

    final response = await manageOtp.reGetOtp();

    // Dismiss loading dialog
    Navigator.pop(context);

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
                Text(
                  '0${widget.phoneNumber}',
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
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
// SendOtp.dart

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:pinput/pinput.dart';
// import 'package:loyalty/components/alert.dart';
// import 'package:loyalty/services/fetch_otp.dart';
// import 'package:loyalty/screen/response/no_internet_page.dart';
// import 'package:loyalty/data/repository/database_repository.dart';
// import 'package:go_router/go_router.dart';
// import 'package:flutter/cupertino.dart';
//
// class SendOtp extends StatefulWidget {
//   final VoidCallback onBack;
//   final String phoneNumber;
//
//   const SendOtp({super.key, required this.onBack, required this.phoneNumber});
//
//   @override
//   State<SendOtp> createState() => _SendOtpState();
// }
//
// class _SendOtpState extends State<SendOtp> {
//   final otpController = TextEditingController();
//
//   Future<void> sendOTP(BuildContext context, String otp) async {
//     try {
//       final manageOtp = ManageOtp();
//       showLoadingDialog(context);
//       final response = await manageOtp.sendOtp(otp);
//       Navigator.pop(context);
//
//       if (response.body == 'otp salah') {
//         if (mounted) {
//           showAlert(
//             context: context,
//             title: 'OTP Salah!',
//             content: 'Silakan periksa OTP Anda dan coba lagi.',
//             type: 'error',
//           );
//         }
//       } else {
//         nextPage(context);
//       }
//     } catch (e) {
//       debugPrint('$e');
//     }
//   }
//
//   Future<void> nextPage(BuildContext context) async {
//     DatabaseRepository databaseRepository = DatabaseRepository();
//     String nama = await databaseRepository.loadUser(field: 'nama');
//     if (nama != "") {
//       context.replaceNamed("home");
//     } else {
//       context.replaceNamed("register");
//     }
//   }
//
//   Future<void> reGenerateOTP(BuildContext context) async {
//     final manageOtp = ManageOtp();
//     showLoadingDialog(context);
//     final response = await manageOtp.reGetOtp();
//     Navigator.pop(context);
//     if (response.statusCode == 200) {
//       if (mounted) {
//         showAlert(
//           context: context,
//           title: 'OTP Dikirim!',
//           content: 'Silakan periksa OTP Anda dan coba lagi.',
//           type: 'info',
//         );
//       }
//     } else {
//       throw Exception('Failed to generate OTP');
//     }
//   }
//
//   void showLoadingDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) {
//         return const Center(
//           child: CircularProgressIndicator(),
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final pinputTheme = PinTheme(
//       width: 38,
//       height: 46,
//       textStyle: const TextStyle(
//         fontSize: 22,
//         color: Colors.black,
//       ),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.transparent),
//       ),
//     );
//
//     return WillPopScope(
//       onWillPop: () async {
//         widget.onBack();
//         return false;
//       },
//       child: InternetAwareWidget(
//         child: Scaffold(
//           appBar: AppBar(
//             leading: GestureDetector(
//               child: const Icon(
//                 Icons.arrow_back_ios_new,
//                 size: 18,
//                 color: Colors.white,
//               ),
//               onTap: () {
//                 widget.onBack();
//               },
//             ),
//             backgroundColor: const Color(0xff0B60B0),
//           ),
//           body: Container(
//             padding: const EdgeInsets.all(16.0),
//             color: const Color(0xff0B60B0),
//             child: Center(
//               child: Column(
//                 children: [
//                   const Text(
//                     'Verifikasi',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 28,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 26),
//                   RichText(
//                     text: const TextSpan(
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w300,
//                         color: Colors.white,
//                       ),
//                       children: <TextSpan>[
//                         TextSpan(text: 'Kami telah mengirimkan '),
//                         TextSpan(
//                           text: 'Kode OTP',
//                           style: TextStyle(fontWeight: FontWeight.w500),
//                         ),
//                         TextSpan(text: ' ke nomor ponsel '),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   Text(
//                     '0${widget.phoneNumber}',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   const SizedBox(height: 46),
//                   Pinput(
//                     autofocus: true,
//                     length: 6,
//                     inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                     defaultPinTheme: pinputTheme,
//                     focusedPinTheme: pinputTheme.copyWith(
//                       decoration: pinputTheme.decoration!.copyWith(
//                         border: Border.all(color: const Color(0xff8F3232)),
//                       ),
//                     ),
//                     onCompleted: (otp) => sendOTP(context, otp),
//                   ),
//                   const SizedBox(height: 46),
//                   const Text(
//                     'Tidak menerima kode?',
//                     style: TextStyle(
//                       color: Colors.white60,
//                       fontSize: 12,
//                       fontWeight: FontWeight.normal,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   GestureDetector(
//                     onTap: () {
//                       reGenerateOTP(context);
//                     },
//                     child: const Text(
//                       'Kirim ulang',
//                       style: TextStyle(
//                         decoration: TextDecoration.underline,
//                         decorationColor: Colors.white60,
//                         color: Colors.white60,
//                         fontSize: 12,
//                         fontWeight: FontWeight.normal,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
