import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:loyalty/data/repository/webview_repository.dart';
import 'package:loyalty/screen/response/no_internet_page.dart';

class Notifications extends StatefulWidget {
  final VoidCallback onGoToHome;
  final void Function(bool, VoidCallback?) updateBackButton;

  const Notifications({
    super.key,
    required this.onGoToHome,
    required this.updateBackButton,
  });

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  late InAppWebViewController _webViewController;
  late PullToRefreshController _pullToRefreshController;
  late Future<String> _urlFuture;

  double _progress = 0;

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

  void _updateBackButtonStatus() async {
    bool canGoBack = await _webViewController.canGoBack();
    widget.updateBackButton(canGoBack, canGoBack ? _handleBackPress : null);
  }

  void _handleBackPress() {
    _webViewController.goBack();
    _updateBackButtonStatus(); // Update back button status after navigating back
  }

  @override
  Widget build(BuildContext context) {
    return InternetAwareWidget(
      child: WillPopScope(
        onWillPop: () async {
          var canGoBack = await _webViewController.canGoBack();
          if (canGoBack) {
            _handleBackPress();
            return false;
          } else {
            widget.onGoToHome();
            return false;
          }
        },
        child: FutureBuilder<String>(
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
              return const Center(
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
                    onWebViewCreated: (controller) {
                      _webViewController = controller;
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
                      _updateBackButtonStatus(); // Update back button status after page load
                    },
                    onProgressChanged: (controller, progress) {
                      setState(() {
                        _progress = progress / 100;
                      });
                    },
                  ),
                  if (_progress < 1)
                    WillPopScope(
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
    );
  }
}
