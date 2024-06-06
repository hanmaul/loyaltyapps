import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:loyalty/screen/response/no_internet_page.dart';

class Notifications extends StatefulWidget {
  final String url;

  const Notifications({
    super.key,
    required this.url,
  });

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final GlobalKey<State> _keyLoader = GlobalKey<State>();
  late final InAppWebViewController _webViewController;
  double _progress = 0;
  String _unRead = '0';

  @override
  void initState() {
    super.initState();
  }

  Future<void> countRead(String unread) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
        "Notifikasi Belum Dibaca = $unread",
        style: TextStyle(fontSize: 16, color: Colors.white),
      )),
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
                onWebViewCreated: (InAppWebViewController controller) {
                  _webViewController = controller;
                  controller.addJavaScriptHandler(
                    handlerName: 'countRead',
                    callback: (args) {
                      String unread = args.join('');
                      //countRead(unread);
                    },
                  );
                },
                onLoadStop: (controller, url) async {
                  await controller.evaluateJavascript(source: """ 
                          const Flutter = {
                              countRead(unread){
                                window.flutter_inappwebview.callHandler('countRead', unread);
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
                            color: Colors.white, // Adjust opacity as needed
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
                  : const SizedBox()
            ],
          ),
        ),
      ),
    );
  }
}
