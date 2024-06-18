import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:loyalty/screen/dashboard.dart';
import 'package:loyalty/screen/auth/get_otp.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:loyalty/screen/response/no_internet_page.dart';
import 'package:loyalty/data/repository/database_repository.dart';

class Akunku extends StatefulWidget {
  final String url;

  const Akunku({
    super.key,
    required this.url,
  });

  @override
  State<Akunku> createState() => _AkunkuState();
}

class _AkunkuState extends State<Akunku> {
  final GlobalKey<State> _keyLoader = GlobalKey<State>();
  late final InAppWebViewController _webViewController;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
  }

  Future<void> dashboard() async {
    await Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return const Dashboard(page: 0);
        },
      ),
      (route) => false,
    );
  }

  Future<void> signOut() async {
    await DatabaseRepository().clearDatabase();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return GetOtp();
        },
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InternetAwareWidget(
      child: WillPopScope(
        onWillPop: () async {
          var isLastPage = await _webViewController.canGoBack();

          if (isLastPage) {
            _webViewController.goBack();
            return false;
          }
          return true;
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              InAppWebView(
                initialUrlRequest: URLRequest(
                  url: WebUri(widget.url),
                ),
                initialSettings: InAppWebViewSettings(
                  supportZoom: false,
                ),
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
                      signOut();
                    },
                  );
                },
                onReceivedError: (controller, request, error) {
                  controller.loadUrl(
                      urlRequest: URLRequest(url: WebUri("about:blank")));
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
              ),
              if (_progress < 1)
                WillPopScope(
                  key: _keyLoader,
                  child: Stack(
                    children: [
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      Center(
                        child: LoadingAnimationWidget.waveDots(
                          color: const Color(0xff0B60B0),
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                  onWillPop: () async => false,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
