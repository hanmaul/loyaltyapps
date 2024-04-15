import 'package:flutter/material.dart';
import 'package:loyalty/screen/auth/get_otp.dart';
import 'package:loyalty/screen/auth/send_otp.dart';
import 'package:loyalty/screen/dashboard.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // controller to keep track of which page we're on
  PageController _controller = PageController();

  // keep track of if we are on the last page or not
  bool onLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        PageView(
          controller: _controller,
          onPageChanged: (index) {
            setState(() {
              onLastPage = (index == 1);
            });
          },
          children: [
            getOtp(),
            sendOtp(),
          ],
        ),

        // dot indicators
        Container(
          alignment: Alignment(0, 0.75),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Previous
              GestureDetector(
                onTap: () {
                  _controller.previousPage(
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeIn,
                  );
                },
                child: Text('previous'),
              ),

              // dot indicator
              SmoothPageIndicator(controller: _controller, count: 2),

              // Next or done
              onLastPage
                  ? GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) {
                            return Dashboard();
                          }),
                        );
                      },
                      child: Text('done'),
                    )
                  : GestureDetector(
                      onTap: () {
                        _controller.nextPage(
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeIn,
                        );
                      },
                      child: Text('next'),
                    ),
            ],
          ),
        ),
      ],
    ));
  }
}
