import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loyalty/data/repository/database_repository.dart';
import 'package:loyalty/screen/dashboard/dashboard.dart';
import 'package:loyalty/screen/terms_of_use.dart';
import 'package:loyalty/screen/webview/register.dart';
import 'package:loyalty/services/fetch_otp.dart';
import 'package:loyalty/services/internet_service.dart';
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
  final internetService = InternetService();

  void sendOTP(String otp) async {
    // Show loading dialog immediately after OTP completion
    showLoadingDialog();

    // Check for internet connection after showing the loading dialog
    if (!await _hasInternetConnection()) {
      return; // Exit the function if no internet
    }

    // Proceed with OTP verification
    await _verifyOtp(otp);
  }

  Future<void> _verifyOtp(String otp) async {
    try {
      final manageOtp = ManageOtp();
      Map<String, dynamic> result = await manageOtp.sendOtp(otp);

      Navigator.pop(context); // Dismiss loading dialog

      if (result['status'] == 'failed') {
        _showError('OTP Salah!', 'Silakan periksa OTP Anda dan coba lagi.');
      } else {
        await _handleNextStep(result);
      }
    } catch (e) {
      Navigator.pop(context); // Dismiss loading dialog on error
      _showError('Gagal!',
          'Gagal memverifikasi OTP. Pastikan koneksi internet Anda stabil atau coba lagi nanti.');
    }
  }

  Future<void> _handleNextStep(Map<String, dynamic> result) async {
    DatabaseRepository databaseRepository = DatabaseRepository();
    String keyExist = await databaseRepository.loadUser(field: "key");

    if (keyExist.isNotEmpty) {
      nextPage();
    } else {
      openTermsOfUse(data: result);
    }
  }

  Future<void> reGenerateOTP() async {
    // Show loading dialog immediately when "Kirim ulang" is pressed
    showLoadingDialog();

    // Check for internet connection after showing the loading dialog
    if (!await _hasInternetConnection()) {
      return; // Exit the function if no internet
    }

    try {
      final manageOtp = ManageOtp();
      final response = await manageOtp.reGetOtp();

      Navigator.pop(context); // Dismiss loading dialog

      if (response.statusCode == 200) {
        // Notify user that a new OTP has been sent
        _showInfo('Kode OTP baru dikirim',
            'Silakan periksa SMS Anda untuk kode baru.');
      } else {
        _showError('Gagal Mengirim OTP!',
            'Terjadi kesalahan. Silakan coba lagi nanti.');
      }
    } catch (e) {
      Navigator.pop(context); // Dismiss loading dialog on error
      _showError('Gagal!',
          'Tidak dapat mengirim OTP. Pastikan koneksi internet Anda stabil atau coba lagi nanti.');
    }
  }

  Future<bool> _hasInternetConnection() async {
    bool hasInternet = await internetService.hasActiveInternetConnection();
    if (!hasInternet) {
      Navigator.pop(context); // Dismiss loading dialog
      _showError('Tidak ada koneksi internet!',
          'Pastikan koneksi internet Anda stabil dan coba lagi.');
      return false;
    }
    return true;
  }

  void _showError(String title, String content) {
    if (mounted) {
      showAlert(
        context: context,
        title: title,
        content: content,
        type: 'error',
      );
    }
  }

  void _showInfo(String title, String content) {
    if (mounted) {
      showAlert(
        context: context,
        title: title,
        content: content,
        type: 'info',
      );
    }
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

  Future<void> nextPage() async {
    DatabaseRepository databaseRepository = DatabaseRepository();
    bool isRegistered = await databaseRepository.isRegistered();
    if (isRegistered) {
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
      byPass: true,
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
