import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/services.dart';
import 'package:loyalty/components/square_tile.dart';
import 'package:loyalty/screen/auth/send_otp.dart';
import 'package:loyalty/services/auth_service.dart';
import 'package:loyalty/services/fetch_otp.dart';
import 'package:loyalty/screen/response/no_internet_page.dart';
import 'package:loyalty/components/alert.dart';

class GetOtp extends StatefulWidget {
  const GetOtp({super.key});

  @override
  State<GetOtp> createState() => _GetOtpState();
}

class _GetOtpState extends State<GetOtp> {
  final country = CountryParser.parseCountryCode("id");
  final phoneController = TextEditingController();
  bool isPhoneNumberValid = false;
  String warningMessage = '';

  @override
  void initState() {
    super.initState();
    // Check for a logout session when the app is launched
    AuthService.checkForLogoutSession(context);
  }

  void generateOTP(String nomor) async {
    String trimmedPhoneNumber = phoneController.text.trim();
    if (trimmedPhoneNumber.isNotEmpty && !trimmedPhoneNumber.startsWith('0')) {
      if (trimmedPhoneNumber.length < 8 || trimmedPhoneNumber.length > 15) {
        showAlert(
          context: context,
          title: 'Nomor tidak valid!',
          content:
              'Nomor ponsel harus memiliki panjang antara 8 hingga 15 digit.',
          type: 'error',
        );
        return;
      }

      showLoadingDialog();
      final manageOtp = ManageOtp(); // Create an instance of ManageOtp
      final response =
          await manageOtp.getOtp(nomor); // Use the instance to call getOtp
      Navigator.pop(context);
      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) {
            return SendOtp(phoneNumber: trimmedPhoneNumber);
          }),
        );
      } else {
        if (mounted) {
          showAlert(
            context: context,
            title: 'Nomor tidak valid!',
            content: 'Silakan periksa nomor Anda dan coba lagi.',
            type: 'error',
          );
        }
      }
    } else if (trimmedPhoneNumber.startsWith('0')) {
      if (mounted) {
        showAlert(
          context: context,
          title: 'Nomor tidak valid!',
          content: 'Masukkan nomor Anda setelah angka 0',
          type: 'error',
        );
      }
    } else {
      if (mounted) {
        showAlert(
          context: context,
          title: 'Nomor kosong!',
          content: 'Mohon input nomor Anda!',
          type: 'error',
        );
      }
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

  void _validatePhoneNumber(String value) {
    setState(() {
      isPhoneNumberValid =
          value.trim().length >= 8 && value.trim().length <= 15;
      warningMessage = isPhoneNumberValid
          ? ''
          : 'Nomor harus terdiri dari 8 hingga 15 digit';
    });
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.transparent),
    );

    return InternetAwareWidget(
      byPass: true,
      child: Scaffold(
        appBar: AppBar(
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SquareTile(imagePath: 'assets/icons/Icon.png'),
            ],
          ),
          backgroundColor: const Color(0xff0B60B0),
        ),
        body: Container(
          padding: const EdgeInsets.all(16.0),
          color: const Color(0xff0B60B0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const SizedBox(height: 15),
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
                            text: 'Nomor Ponsel',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          TextSpan(text: ' Anda untuk melanjutkan'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextFormField(
                        autofocus: true,
                        controller: phoneController,
                        style: const TextStyle(
                          fontSize: 22,
                        ),
                        onChanged: _validatePhoneNumber,
                        onFieldSubmitted: (phoneNumber) {
                          generateOTP(phoneController.text.toString());
                        },
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                          filled: true,
                          contentPadding: EdgeInsets.zero,
                          fillColor: Colors.white,
                          enabledBorder: border,
                          focusedBorder: border,
                          hintText: '811XXXXXXXX',
                          hintStyle: const TextStyle(color: Colors.black26),
                          prefixIcon: Container(
                            height: 10,
                            width: 85,
                            alignment: Alignment.center,
                            child: Text(
                              '${country.flagEmoji} +${country.phoneCode}',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        enableInteractiveSelection: false,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (warningMessage.isNotEmpty)
                      Text(
                        warningMessage,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    const SizedBox(height: 18),
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(
                          height: 1.3,
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                              text: 'Dengan melanjutkan, Anda menyetujui '),
                          TextSpan(
                            text: 'Syarat & Ketentuan',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          TextSpan(text: ' dan '),
                          TextSpan(
                            text: 'Kebijakan Privasi',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          TextSpan(text: ' kami'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10.0),
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.black12.withOpacity(0.1),
                        border: Border.all(
                          width: 5,
                          color: Colors.transparent,
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(6)),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.warning,
                            color: Colors.amber,
                            size: 24.0,
                          ),
                          SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              "Hati-hati terhadap penipuan karena kami tidak pernah memberikan link, meminta PIN, kata sandi atau uang.",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w300,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    generateOTP(phoneController.text.toString());
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 32.0),
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    child: const Text(
                      'LANJUT',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
