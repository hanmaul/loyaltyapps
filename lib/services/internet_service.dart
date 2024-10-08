import 'package:http/http.dart' as http;

class InternetService {
  // This function checks if there's an actual internet connection
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
