import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:loyalty/components/alert.dart';
import 'package:loyalty/data/repository/webview_repository.dart';
import 'package:loyalty/screen/dashboard/dashboard.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:loyalty/screen/response/no_internet_page.dart';
import 'package:loyalty/data/repository/database_repository.dart';
import 'package:loyalty/services/auth_service.dart';

class Akunku extends StatefulWidget {
  final VoidCallback onGoToHome;
  const Akunku({super.key, required this.onGoToHome});

  @override
  State<Akunku> createState() => _AkunkuState();
}

class _AkunkuState extends State<Akunku> {
  final GlobalKey<State> _keyLoader = GlobalKey<State>();
  late final InAppWebViewController _webViewController;
  double _progress = 0;
  late Future<String> _urlFuture;
  String _appVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    _urlFuture = WebviewRepository().getUrlAkunku();
    getVersion();
  }

  Future<void> getVersion() async {
    DatabaseRepository databaseRepository = DatabaseRepository();
    String version = await databaseRepository.loadUser(field: "appVersion");
    setState(() {
      _appVersion = version;
    });
  }

  String _injectVersionIntoWebView() {
    return """
    if (!document.getElementById('app-version')) {
      var versionElement = document.createElement('div');
      versionElement.id = 'app-version';
      versionElement.innerText = 'App Version: $_appVersion';
      versionElement.style.bottom = '0';
      versionElement.style.width = '100%';
      versionElement.style.textAlign = 'center';
      versionElement.style.backgroundColor = '#FFF'; // Change as needed
      versionElement.style.marginTop = '10px'; // Adjust as needed
      versionElement.style.marginBottom = '10px'; // Adjust as needed
      document.body.appendChild(versionElement);
    }
  """;
  }

  Future<void> _logout() async {
    showAlert(
      context: context,
      title: 'Logout',
      content: 'Apakah Anda yakin ingin keluar?',
      type: 'info',
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop(); // Close the dialog
            await AuthService.signOutByUser(context); // Proceed with logout
          },
          child: const Text(
            'Keluar',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
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
                      onWebViewCreated: (InAppWebViewController controller) {
                        _webViewController = controller;
                        controller.addJavaScriptHandler(
                          handlerName: 'dashboard',
                          callback: (args) {
                            dashboard();
                          },
                        );
                        controller.addJavaScriptHandler(
                          handlerName: 'logout',
                          callback: (args) {
                            _logout();
                          },
                        );
                      },
                      // onReceivedError: (controller, request, error) {
                      //   controller.loadUrl(
                      //       urlRequest: URLRequest(url: WebUri("about:blank")));
                      // },
                      onLoadStop: (controller, url) async {
                        String script = _injectVersionIntoWebView();
                        await controller.evaluateJavascript(source: script);

                        await controller.evaluateJavascript(source: """
                            const Flutter = {
                                home(){
                                  window.flutter_inappwebview.callHandler('dashboard', 'home');
                                },
                                logout(){
                                  window.flutter_inappwebview.callHandler('logout', 'removeSession');
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
