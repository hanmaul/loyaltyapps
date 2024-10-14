import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:loyalty/data/repository/webview_repository.dart';
import 'package:loyalty/screen/response/no_internet_page.dart';
import 'package:loyalty/screen/response/webview_error_page.dart';
import 'package:loyalty/services/filter_error.dart';

class History extends StatefulWidget {
  final VoidCallback onGoToHome;
  const History({super.key, required this.onGoToHome});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  final GlobalKey<State> _keyLoader = GlobalKey<State>();
  late final InAppWebViewController _webViewController;
  double _progress = 0;
  late Future<String> _urlFuture;
  String? _currentUrl;

  bool _hasError = false;
  String errorType = '';
  String errorImage = '';
  String errorMessage = '';
  VoidCallback errorAction = () {};

  @override
  void initState() {
    super.initState();
    _urlFuture = WebviewRepository().getUrlHistory();
  }

  void receivedError(Map<String, String> error) {
    setState(() {
      _progress = 100;
      errorType = error['errorType']!;
      errorImage = error['imagePath']!;
      errorMessage = error['message']!;
      _hasError = true;
      errorAction = _retryWebView;
    });
  }

  void _retryWebView() {
    if (_currentUrl != null) {
      setState(() {
        _progress = 0;
        _hasError = false;
      });
      _webViewController.loadUrl(
        urlRequest: URLRequest(url: WebUri(_currentUrl!)),
      ); // Use the stored URL to load the page.
    }
  }

  @override
  Widget build(BuildContext context) {
    return InternetAwareWidget(
      byPass: true,
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
                return const Center(
                  child: Text('No URL found'),
                );
              } else {
                _currentUrl = snapshot.data;

                return Stack(
                  children: [
                    InAppWebView(
                      initialUrlRequest: URLRequest(
                        url: WebUri(snapshot.data!),
                      ),
                      initialSettings: InAppWebViewSettings(
                        supportZoom: false,
                        disableDefaultErrorPage: true,
                      ),
                      onWebViewCreated: (InAppWebViewController controller) {
                        _webViewController = controller;
                      },
                      onReceivedError: (controller, request, error) {
                        final errorDetails =
                            FilterErrorService.filterError(error.type);
                        receivedError(errorDetails);
                      },
                      // onReceivedHttpError:
                      //     (controller, request, errorResponse) {
                      //   final errorDetails = FilterErrorService.filterHttpError(
                      //     errorResponse.statusCode ?? 0,
                      //   );
                      //   receivedError(errorDetails);
                      // },
                      onJsAlert: (controller, jsAlertRequest) async {
                        return JsAlertResponse(
                          handledByClient: true,
                          action: JsAlertResponseAction.CONFIRM,
                        );
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
                    if (_hasError)
                      WebViewErrorPage(
                        type: errorType,
                        message: errorMessage,
                        imagePath: errorImage,
                        onRetry: errorAction,
                      )
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
