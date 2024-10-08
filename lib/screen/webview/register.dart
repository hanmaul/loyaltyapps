import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:loyalty/data/repository/webview_repository.dart';
import 'package:loyalty/data/repository/database_repository.dart';
import 'package:loyalty/screen/dashboard/dashboard.dart';
import 'package:loyalty/screen/response/no_internet_page.dart';
import 'package:loyalty/screen/response/webview_error_page.dart';
import 'package:loyalty/services/filter_error.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final GlobalKey<State> _keyLoader = GlobalKey<State>();
  late final InAppWebViewController _webViewController;
  final DatabaseRepository databaseRepository = DatabaseRepository();
  double _progress = 0;
  late Future<String> _urlFuture;

  bool _hasError = false;
  String errorType = '';
  String errorImage = '';
  String errorMessage = '';
  VoidCallback errorAction = () {};

  @override
  void initState() {
    super.initState();
    _urlFuture = WebviewRepository().getUrlRegister();
  }

  Future<void> dashboard() async {
    registered(); // Change isRegistered to true after user register
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

  Future<void> saveNama(String nama) async {
    await databaseRepository.updateUser(field: 'nama', data: nama);
  }

  Future<void> registered() async {
    await databaseRepository.registered();
  }

  void receivedError(Map<String, String> error) {
    setState(() {
      _progress = 100;
      errorType = error['errorType']!;
      errorImage = error['imagePath']!;
      errorMessage = error['message']!;
      _hasError = true;
      errorAction = _retryWebView; // Retry for other errors
    });
  }

  void _retryWebView() {
    setState(() {
      _progress = 0;
      _hasError = false;
    });
    _webViewController.reload(); // Reload the same page when retrying
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
          appBar: AppBar(
            title: const Text(
              "Registrasi",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            backgroundColor: const Color(0xff0B60B0),
          ),
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
                return Stack(
                  children: [
                    if (!_hasError)
                      InAppWebView(
                        initialUrlRequest: URLRequest(
                          url: WebUri(snapshot.data!),
                        ),
                        initialSettings: InAppWebViewSettings(
                          supportZoom: false,
                          disableDefaultErrorPage: true,
                        ),
                        onReceivedError: (controller, request, error) {
                          debugPrint('RESULT ERROR : ${error.type.toString()}');
                          final errorDetails =
                              FilterErrorService.filterError(error.type);
                          receivedError(errorDetails);
                        },
                        onReceivedHttpError:
                            (controller, request, errorResponse) {
                          debugPrint(
                              'RESULT ERROR : ${errorResponse.statusCode.toString()}');
                          final errorDetails =
                              FilterErrorService.filterHttpError(
                            errorResponse.statusCode ?? 0,
                          );
                          receivedError(errorDetails);
                        },
                        onWebViewCreated: (InAppWebViewController controller) {
                          _webViewController = controller;
                          controller.addJavaScriptHandler(
                            handlerName: 'dashboard',
                            callback: (args) {
                              dashboard();
                            },
                          );

                          controller.addJavaScriptHandler(
                            handlerName: 'saveNama',
                            callback: (args) {
                              String nama = args.join('');
                              saveNama(nama);
                            },
                          );
                        },
                        onLoadStop: (controller, url) async {
                          await controller.evaluateJavascript(source: """ 
                          const Flutter = {
                              getNama(nama){
                                window.flutter_inappwebview.callHandler('saveNama', nama);
                              },
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
