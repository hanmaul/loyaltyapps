import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:loyalty/screen/response/no_internet_page.dart';

class History extends StatefulWidget {
  final String url;

  const History({
    super.key,
    required this.url,
  });

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  final GlobalKey<State> _keyLoader = GlobalKey<State>();
  late final InAppWebViewController _webViewController;
  double _progress = 0;

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
                },
                onReceivedError: (controller, request, error) {
                  controller.loadUrl(
                      urlRequest: URLRequest(url: WebUri("about:blank")));
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
