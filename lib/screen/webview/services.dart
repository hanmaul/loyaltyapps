import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:loyalty/screen/dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

final keepAlive = InAppWebViewKeepAlive();

class WebviewServices extends StatefulWidget {
  const WebviewServices({super.key});

  @override
  State<WebviewServices> createState() => _WebviewServicesState();
}

class _WebviewServicesState extends State<WebviewServices> {
  final GlobalKey<State> _keyLoader = GlobalKey<State>();
  late final InAppWebViewController _webViewController;
  double _progress = 0;
  String url = "";
  String urlTitle = "";

  getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      url = pref.getString("url")!;
      urlTitle = pref.getString("url_title")!;
    });
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //       content: Text(
    //     "Ini url nya : $url",
    //     style: const TextStyle(fontSize: 16, color: Colors.yellow),
    //   )),
    // );
  }

  @override
  void initState() {
    getPref();
    super.initState();
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
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          url != ""
              ? InAppWebView(
                  initialUrlRequest: URLRequest(
                    url: WebUri(url),
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
