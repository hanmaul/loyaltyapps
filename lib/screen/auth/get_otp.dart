import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:loyalty/components/square_tile.dart';
import 'package:http/http.dart' as http;
import 'package:loyalty/screen/auth/send_otp.dart';
import 'package:shared_preferences/shared_preferences.dart';

class getOtp extends StatefulWidget {
  const getOtp({super.key});

  @override
  State<getOtp> createState() => _getOtpState();
}

class _getOtpState extends State<getOtp> {
  Country? country;

  final phoneController = TextEditingController();

  Future<String> fetchCountryCode() async {
    // final response = await http.get(Uri.parse('http://ip-api.com/json'));
    // final body = json.decode(response.body);
    // final countryCode = body['countryCode'];
    // return countryCode;
    return 'ID';
  }

  void generateOTP(String nomor) async {
    if (phoneController.text != '') {
      final response = await http.post(
        Uri.parse('https://www.kamm-group.com:8070/fapi/autocust'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'nohp': '0' + nomor,
        }),
      );

      List<dynamic> output = jsonDecode(response.body);
      Map<String, dynamic> result = output[0];

      if (response.statusCode == 200) {
        saveSession(result['No_hp']);
      } else {
        throw Exception('Failed to generate OTP');
      }
    } else {
      debugPrint('field kosong');
    }
  }

  void saveSession(String nomor) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString("nomor", nomor);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return sendOtp();
      }),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchCountryCode().then((countryCode) {
      setState(() {
        country = CountryParser.parseCountryCode(countryCode);
      });
    });
  }

  void showPicker() {
    showCountryPicker(
      context: context,
      favorite: ['ID'],
      countryListTheme: CountryListThemeData(
        bottomSheetHeight: 600,
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(20),
        inputDecoration: const InputDecoration(
          prefixIcon: Icon(
            Icons.search,
            color: Color(0xff0B60B0),
          ),
          hintText: 'Cari negara Anda di sini..',
          border: InputBorder.none,
        ),
      ),
      onSelect: (country) {
        setState(() {
          this.country = country;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.transparent),
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
                  country == null
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: TextFormField(
                            autofocus: true,
                            controller: phoneController,
                            style: const TextStyle(
                              fontSize: 22,
                            ),
                            onFieldSubmitted: (phoneNumber) {
                              generateOTP(phoneController.text.toString());
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      // Text('+${country!.phoneCode}$phoneNumber'),
                                      Text(
                                          'Kode OTP dikirim ke WhatsApp Anda!'),
                                ),
                              );
                            },
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              filled: true,
                              contentPadding: EdgeInsets.zero,
                              fillColor: Colors.white,
                              enabledBorder: border,
                              focusedBorder: border,
                              hintText: '811-1234-5678',
                              hintStyle: const TextStyle(color: Colors.black26),
                              prefixIcon: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: showPicker,
                                child: Container(
                                  height: 10,
                                  width: 85,
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${country!.flagEmoji} +${country!.phoneCode}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(height: 24),
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
                        TextSpan(text: 'Dengan melanjutkan, Anda menyetujui '),
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
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
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
                            'Hati-hati terhadap penipuan karena kami tidak pernah memberikan link, meminta PIN, kode OTP, atau uang.',
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
    );
  }
}
