import 'dart:io' show Platform;
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

class SettingsService {
  Future<void> openPhoneSettings() async {
    if (Platform.isAndroid) {
      const intent = AndroidIntent(
        action: 'android.settings.WIRELESS_SETTINGS',
      );
      await intent.launch();
    } else if (Platform.isIOS) {
      Uri settingsUrl = Uri.parse('app-settings:');
      if (await canLaunchUrl(settingsUrl)) {
        await launchUrl(settingsUrl);
      } else {
        throw 'Could not open settings';
      }
    }
  }
}
