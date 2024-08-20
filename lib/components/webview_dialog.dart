import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewDialog extends StatefulWidget {
  final String url;

  WebViewDialog({required this.url});

  @override
  _WebViewDialogState createState() => _WebViewDialogState();
}

class _WebViewDialogState extends State<WebViewDialog> {
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Stack(
        alignment: Alignment.topRight,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(10.0),
            color: Colors.white,
            height: 500,
            child: Stack(
              children: [
                InAppWebView(
                  initialUrlRequest: URLRequest(
                    url: WebUri(widget.url),
                  ),
                  initialSettings: InAppWebViewSettings(
                    supportZoom: false,
                    transparentBackground: true,
                  ),
                  onLoadStart: (controller, url) {
                    setState(() {
                      _isLoading = true;
                    });
                  },
                  onLoadStop: (controller, url) async {
                    setState(() {
                      _isLoading = false;
                    });
                  },
                ),
                if (_isLoading)
                  Container(
                    color: Colors.white,
                    width: double.infinity,
                    height: double.infinity,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            top: 5,
            right: 5,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
