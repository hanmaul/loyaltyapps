import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewService {
  Future<void> clearCache() async {
    await InAppWebViewController.clearAllCache();
  }
}
