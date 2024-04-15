import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:loyalty/screen/dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loyalty/screen/auth/get_otp.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

final keepAlive = InAppWebViewKeepAlive();

class Akunku extends StatefulWidget {
  const Akunku({super.key});

  @override
  State<Akunku> createState() => _AkunkuState();
}

class _AkunkuState extends State<Akunku>
    with AutomaticKeepAliveClientMixin<Akunku> {
  final GlobalKey<State> _keyLoader = GlobalKey<State>();
  late final InAppWebViewController _webViewController;
  double _progress = 0;
  String key = "";

  @override
  void initState() {
    super.initState();
    getKey();
  }

  getKey() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      key = pref.getString('key')!;
    });
  }

  Future<void> dashboard() async {
    await Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return const Dashboard();
        },
      ),
      (route) => false,
    );
  }

  Future<void> removeSession() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return getOtp();
        },
      ),
      (route) => false,
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Profile",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xff0B60B0),
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          key != ""
              ? InAppWebView(
                  keepAlive: keepAlive,
                  initialUrlRequest: URLRequest(
                    url: WebUri(
                        "http://mobilekamm.ddns.net:8065/m_mlp/mobile/akun/profile?key=$key"),
                  ),
                  // onReceivedServerTrustAuthRequest:
                  //     (controller, challenge) async {
                  //   return ServerTrustAuthResponse(
                  //       action: ServerTrustAuthResponseAction.PROCEED);
                  // },
                  onWebViewCreated: (InAppWebViewController controller) {
                    _webViewController = controller;
                    controller.addJavaScriptHandler(
                      handlerName: 'dashboard',
                      callback: (args) {
                        dashboard();
                      },
                    );
                    controller.addJavaScriptHandler(
                      handlerName: 'logout',
                      callback: (args) {
                        removeSession();
                      },
                    );
                  },
                  onLoadStop: (controller, url) async {
                    await controller.evaluateJavascript(source: """ 
                      const Flutter = {
                          home(){
                            window.flutter_inappwebview.callHandler('dashboard', 'home');
                          },
                          logout(){
                            window.flutter_inappwebview.callHandler('logout', 'removeSession');
                          },
                     }
                      """);
                  },
                  onProgressChanged:
                      (InAppWebViewController controller, int progress) {
                    setState(() {
                      _progress = progress / 100;
                    });
                  },
                )
              : Stack(
                  children: [
                    Container(
                      color: Colors.black
                          .withOpacity(0.5), // Adjust opacity as needed
                      width: double.infinity,
                      height: double.infinity,
                    ),
                    const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Colors.white, // Change the color as needed
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
          _progress < 1
              ? WillPopScope(
                  key: _keyLoader,
                  child: Stack(
                    children: [
                      Container(
                        color: Colors.black
                            .withOpacity(0.7), // Adjust opacity as needed
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      Center(
                        child: LoadingAnimationWidget.fourRotatingDots(
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                  onWillPop: () async => false,
                )
              : const SizedBox()
        ],
      ),
    );
  }
}
