import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:loyalty/services/fetch_location.dart';
import 'package:loyalty/services/fetch_version.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:loyalty/screen/response/no_internet_page.dart';

class Content extends StatefulWidget {
  final String title;
  final String url;

  const Content({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<Content> createState() => _ContentState();
}

class _ContentState extends State<Content> {
  final GlobalKey<State> _keyLoader = GlobalKey<State>();
  late InAppWebViewController _webViewController;
  double _progress = 0;
  String currentUrl = '';

  @override
  void initState() {
    super.initState();
    fetchVersion();
    fetchGPS();
  }

  Future<void> fetchVersion() async {
    AppVersion appVersion = AppVersion();
    final currentVersion = await appVersion.getVersion();
    setState(() {
      currentUrl = appendVersionToUrl(currentVersion);
    });
  }

  String getAfterLastSlash() {
    return widget.url.substring(widget.url.lastIndexOf('/') + 1);
  }

  bool checkIfContains(String keyword) {
    String afterLastSlash = getAfterLastSlash();
    return afterLastSlash.contains(keyword);
  }

  String appendVersionToUrl(String version) {
    bool containsQuestionMark = checkIfContains('?');

    if (containsQuestionMark) {
      return '${widget.url}&version=$version';
    } else {
      return '${widget.url}?version=$version';
    }
  }

  // Function to fetch location and set it in WebView's localStorage
  Future<void> fetchGPS() async {
    if (currentUrl.contains("re-order")) {
      FetchLocation fetchLocation = FetchLocation();
      try {
        // Fetch latitude and longitude
        Map<String, double> position = await fetchLocation.getCurrentPosition();
        double latitude = position['latitude']!;
        double longitude = position['longitude']!;

        // Inject JavaScript to set latitude and longitude in localStorage
        String jsCode = """
        window.localStorage.setItem('latitude', '$latitude');
        window.localStorage.setItem('longitude', '$longitude');
      """;

        if (_webViewController != null) {
          await _webViewController.evaluateJavascript(source: jsCode);
        }
      } catch (e) {
        print("Error fetching location: $e");
      }
    } else {
      return;
    }
  }

  Future<bool> checkGPS() async {
    FetchLocation fetchLocation = FetchLocation();

    try {
      // Validate GPS and permissions
      bool isGpsEnabled =
          await fetchLocation.validateGPSAndPermissions(context);

      if (isGpsEnabled) {
        return true; // GPS is enabled
      } else {
        return false; // GPS is disabled
      }
    } catch (e) {
      print("Error checking GPS: $e");
      return false; // Return false in case of an error
    }
  }

  Future<void> back() async {
    bool canGoBack = await _webViewController.canGoBack();
    if (canGoBack) {
      _webViewController.goBack();
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> dashboard() async {
    Navigator.pop(context);
  }

  void openScanner() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              AppBar(
                title: const Text('Scan Kode Referral '),
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                leading: GestureDetector(
                  child: const Icon(
                    Icons.close,
                    color: Colors.black,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: MobileScanner(
                      controller: MobileScannerController(
                        detectionSpeed: DetectionSpeed.noDuplicates,
                        returnImage: false,
                      ),
                      onDetect: (capture) {
                        final List<Barcode> barcodes = capture.barcodes;
                        for (final barcode in barcodes) {
                          if (barcode.rawValue != null) {
                            try {
                              final Map<String, dynamic> barcodeData =
                                  json.decode(barcode.rawValue!);
                              final String custId = barcodeData['cust_id'];
                              Navigator.pop(context); // Close the scanner
                              setState(() {
                                currentUrl =
                                    "${widget.url}&kode_referal=$custId";
                              });
                              _webViewController.loadUrl(
                                urlRequest: URLRequest(url: WebUri(currentUrl)),
                              );
                              break; // Exit the loop after processing the first barcode
                            } catch (e) {
                              debugPrint('Failed to parse barcode data: $e');
                            }
                          }
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDatun = checkIfContains('datun');

    return InternetAwareWidget(
      child: WillPopScope(
        onWillPop: () async {
          bool canGoBack = await _webViewController.canGoBack();
          if (canGoBack) {
            _webViewController.goBack();
            return false;
          } else {
            Navigator.pop(context);
            return false;
          }
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xff0B60B0),
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                back();
              },
            ),
            title: Text(
              widget.title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            actions: [
              if (isDatun)
                IconButton(
                  icon: const Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    openScanner();
                  },
                ),
            ],
          ),
          backgroundColor: Colors.white,
          body: currentUrl.isEmpty
              ? Center(
                  child: LoadingAnimationWidget.waveDots(
                    color: const Color(0xff0B60B0),
                    size: 32,
                  ),
                )
              : Stack(
                  children: [
                    InAppWebView(
                      initialUrlRequest: URLRequest(
                        url: WebUri(currentUrl),
                      ),
                      initialSettings: InAppWebViewSettings(
                        supportZoom: false,
                        transparentBackground: true,
                      ),
                      onWebViewCreated: (InAppWebViewController controller) {
                        _webViewController = controller;
                        controller.addJavaScriptHandler(
                          handlerName: 'fetchLocation',
                          callback: (args) {
                            fetchGPS();
                          },
                        );
                        controller.addJavaScriptHandler(
                          handlerName: 'dashboard',
                          callback: (args) {
                            dashboard();
                          },
                        );
                        controller.addJavaScriptHandler(
                          handlerName: 'checkGPS',
                          callback: (args) async {
                            bool gpsEnabled = await checkGPS();
                            return gpsEnabled;
                          },
                        );
                      },
                      onLoadStop: (controller, url) async {
                        await fetchGPS();
                        await controller.evaluateJavascript(source: """ 
                        const Flutter = {
                            home: function() {
                                window.flutter_inappwebview.callHandler('dashboard', 'home');
                            },
                            fetchLocation: function() {
                                window.flutter_inappwebview.callHandler('fetchLocation', 'gps');
                            },
                            checkgps: function() {
                                return window.flutter_inappwebview.callHandler('checkGPS', 'gps')
                                    .then(result => {
                                        return result;  // Return the result of the GPS check to be used in JavaScript
                                    })
                                    .catch(error => {
                                        console.error('Error in checkGPS:', error);  // Handle any potential error
                                    });
                            }
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
                ),
        ),
      ),
    );
  }
}
