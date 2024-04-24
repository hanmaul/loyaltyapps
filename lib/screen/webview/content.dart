import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:loyalty/screen/dashboard.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Content extends StatefulWidget {
  final String title;
  final String url;

  const Content({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<Content> createState() => _ContentState();
}

class _ContentState extends State<Content> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
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
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(widget.url),
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
          ),
          _progress < 1
              ? WillPopScope(
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
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}
