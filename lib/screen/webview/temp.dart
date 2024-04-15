import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:loyalty/screen/dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loyalty/screen/auth/get_otp.dart';

final keepAlive = InAppWebViewKeepAlive();

class Akunku extends StatefulWidget {
  const Akunku({super.key});

  @override
  State<Akunku> createState() => _AkunkuState();
}

class _AkunkuState extends State<Akunku>
    with AutomaticKeepAliveClientMixin<Akunku> {
  late final InAppWebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    getKey();
  }

  Future<String> getKey() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString('key') ?? '';
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

    return FutureBuilder<String>(
      future: getKey(), // Asynchronously fetch preference
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        } else {
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')),
            );
          } else {
            String key = snapshot.data ?? '';
            // Use the value to render WebView or anything else
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
              body: Stack(
                children: [
                  InAppWebView(
                    keepAlive: keepAlive,
                    initialUrlRequest: URLRequest(
                      url: WebUri(
                          "http://mobilekamm.ddns.net:8065/m_mlp/mobile/akun/profile?key=$key"),
                    ),
                    onReceivedServerTrustAuthRequest:
                        (controller, challenge) async {
                      return ServerTrustAuthResponse(
                          action: ServerTrustAuthResponseAction.PROCEED);
                    },
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
                  ),
                ],
              ),
            );
          }
        }
      },
    );
  }
}
