// import 'package:flutter/material.dart';
// import 'package:loyalty/screen/auth/get_otp.dart';
// import 'package:loyalty/screen/auth/send_otp.dart';
//
// class OTP extends StatefulWidget {
//   final int page;
//   const OTP({super.key, required this.page});
//
//   @override
//   State<OTP> createState() => _OTPState();
// }
//
// class _OTPState extends State<OTP> {
//   int _currentPageIndex = 0;
//   String phoneNumber = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _currentPageIndex = widget.page;
//   }
//
//   void _showGetOtpPage() {
//     setState(() {
//       _currentPageIndex = 0;
//     });
//   }
//
//   void _showSendOtpPage(String phone) {
//     setState(() {
//       phoneNumber = phone;
//       _currentPageIndex = 1;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return _currentPageIndex == 0
//         ? GetOtp(onNext: _showSendOtpPage)
//         : SendOtp(onBack: _showGetOtpPage, phoneNumber: phoneNumber);
//   }
// }
