import 'package:flutter/material.dart';
import 'package:loyalty/screen/auth/get_otp.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'dashboard.dart';

class Introduction extends StatefulWidget {
  const Introduction({super.key});

  @override
  State<Introduction> createState() => _IntroductionState();
}

class _IntroductionState extends State<Introduction> {
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
            Container(
              child: Center(
                child: Text('1'),
              ),
            ),
            Container(
              child: Center(
                child: Text('2'),
              ),
            ),
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
                            return getOtp();
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
