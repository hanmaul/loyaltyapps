import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "History",
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
    );
  }
}
