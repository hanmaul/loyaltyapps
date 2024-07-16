import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:loyalty/screen/response/no_internet_page.dart';

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

  Future<void> back() async {
    var isLastPage = await _webViewController.canGoBack();
    if (isLastPage) {
      _webViewController.goBack();
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> dashboard() async {
    Navigator.pop(context);
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
          } else {
            Navigator.pop(context);
            return false;
          }
        },
        child: Scaffold(
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
                back();
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
                },
                // onReceivedError: (controller, request, error) {
                //   controller.loadUrl(
                //       urlRequest: URLRequest(url: WebUri("about:blank")));
                // },
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
