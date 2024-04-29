import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:loyalty/screen/dashboard.dart';
import 'package:loyalty/data/repository/preferences_repository.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:loyalty/screen/no_internet_page.dart';

class Register extends StatefulWidget {
  final String url;

  const Register({
    super.key,
    required this.url,
  });

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final GlobalKey<State> _keyLoader = GlobalKey<State>();
  late final InAppWebViewController _webViewController;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
  }

  Future<void> saveNama(String nama) async {
    await PrefRepository().setName(nama);
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
                : const SizedBox()
          ],
        ),
      ),
    );
  }
}
