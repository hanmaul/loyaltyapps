import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:loyalty/data/repository/webview_repository.dart';
import 'package:loyalty/screen/response/no_internet_page.dart';

class Notifications extends StatefulWidget {
  final VoidCallback onGoToHome;
  const Notifications({super.key, required this.onGoToHome});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final GlobalKey<State> _keyLoader = GlobalKey<State>();
  late final InAppWebViewController _webViewController;
  late PullToRefreshController _pullToRefreshController;
  late Future<String> _urlFuture;

  double _progress = 0;
  String _unRead = '0';

  @override
  void initState() {
    super.initState();
    _urlFuture = WebviewRepository().getUrlNotifikasi();
    _pullToRefreshController = PullToRefreshController(
      settings: PullToRefreshSettings(
        color: const Color(0xff0B60B0),
      ),
      onRefresh: () async {
        await _webViewController.reload();
        _pullToRefreshController.endRefreshing();
      },
    );
  }

  Future<void> countRead(String unread) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
        "Notifikasi Belum Dibaca = $unread",
        style: const TextStyle(fontSize: 16, color: Colors.white),
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
          } else {
            widget.onGoToHome();
            return false;
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: FutureBuilder<String>(
            future: _urlFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: LoadingAnimationWidget.waveDots(
                    color: const Color(0xff0B60B0),
                    size: 32,
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text('No URL found'),
                );
              } else {
                return Stack(
                  children: [
                    InAppWebView(
                      initialUrlRequest: URLRequest(
                        url: WebUri(snapshot.data!),
                      ),
                      initialSettings: InAppWebViewSettings(
                        supportZoom: false,
                      ),
                      pullToRefreshController: _pullToRefreshController,
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
                      onReceivedError: (controller, request, error) {
                        controller.loadUrl(
                            urlRequest: URLRequest(url: WebUri("about:blank")));
                      },
                      onLoadStop: (controller, url) async {
                        await controller.evaluateJavascript(source: """ 
                        document.body.style.minHeight = '101vh';
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
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
