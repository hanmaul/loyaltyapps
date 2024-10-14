import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

class InternetService {
  Future<bool> hasActiveConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();

    // If the result is anything other than 'none', it means the user is connected to some network
    if (connectivityResult != ConnectivityResult.none) {
      return true; // User is connected to Wi-Fi, mobile, or Ethernet
    }
    return false; // No active connection
  }

  Future<bool> hasActiveInternetConnection() async {
    try {
      // Perform a GET request to a reliable server
      final response = await http
          .get(Uri.parse('http://www.google.com/generate_204'))
          .timeout(
            const Duration(seconds: 5), // Set a timeout of 5 seconds
          );

      // If the response is 204 (No Content), the internet is available
      return response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}
