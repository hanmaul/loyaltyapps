import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:loyalty/screen/dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final GlobalKey<State> _keyLoader = GlobalKey<State>();
  late final InAppWebViewController _webViewController;
  double _progress = 0;
  String key = "";

  @override
  void initState() {
    super.initState();
    getKey();
  }

  getKey() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      key = pref.getString("key")!;
    });
  }

  Future<void> saveNama(String nama) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString("nama", nama);
  }

  Future<void> dashboard() async {
    await Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return const Dashboard();
        },
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Registrasi",
          style: TextStyle(
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
          key != ""
              ? InAppWebView(
                  initialUrlRequest: URLRequest(
                    url: WebUri(
                        "http://mobilekamm.ddns.net:8065/m_mlp/mobile/akun/registrasi/data-diri?key=$key"),
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
                )
              : Stack(
                  children: [
                    Container(
                      color: Colors.black
                          .withOpacity(0.5), // Adjust opacity as needed
                      width: double.infinity,
                      height: double.infinity,
                    ),
                    const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Colors.white, // Change the color as needed
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
          _progress < 1
              ? WillPopScope(
                  key: _keyLoader,
                  child: Stack(
                    children: [
                      Container(
                        color: Colors.black
                            .withOpacity(0.7), // Adjust opacity as needed
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      Center(
                        child: LoadingAnimationWidget.fourRotatingDots(
                          color: Colors.white,
                          size: 34,
                        ),
                      ),
                    ],
                  ),
                  onWillPop: () async => false,
                )
              : const SizedBox()
        ],
      ),
    );
  }
}
