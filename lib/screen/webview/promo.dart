import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:loyalty/screen/dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WebviewPromo extends StatefulWidget {
  const WebviewPromo({super.key});

  @override
  State<WebviewPromo> createState() => _WebviewPromoState();
}

class UrlData {
  final String url;
  final String urlTitle;

  UrlData(this.url, this.urlTitle);
}

class _WebviewPromoState extends State<WebviewPromo> {
  late final InAppWebViewController _webViewController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    getUrl();
  }

  Future<UrlData> getUrl() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String url = pref.getString('url') ?? '';
    String urlTitle = pref.getString('url_title') ?? '';
    return UrlData(url, urlTitle);
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UrlData>(
      future: getUrl(), // Asynchronously fetch preference
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Change this line
          return const Scaffold(
            backgroundColor: Colors.transparent,
          );
        } else {
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')),
            );
          } else {
            String url = snapshot.data?.url ?? '';
            String urlTitle = snapshot.data?.urlTitle ?? '';
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  urlTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                backgroundColor: const Color(0xff0B60B0),
              ),
              body: Stack(
                children: [
                  InAppWebView(
                    initialUrlRequest: URLRequest(
                      url: WebUri(url),
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
                    },
                    onLoadStop: (controller, url) async {
                      await controller.evaluateJavascript(source: """ 
                    const Flutter = {
                        home(){
                          window.flutter_inappwebview.callHandler('dashboard', 'home');
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
