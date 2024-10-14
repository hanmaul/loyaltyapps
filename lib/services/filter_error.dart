import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class FilterErrorService {
  // This method filters the WebView errors and returns the error type, image path, and message
  static Map<String, String> filterError(WebResourceErrorType errorType) {
    // Log the error type for debugging
    print('ERROR LOADING - TYPE : ${errorType.toString()}');

    if (errorType == WebResourceErrorType.TIMEOUT ||
        errorType == WebResourceErrorType.NOT_CONNECTED_TO_INTERNET ||
        errorType == WebResourceErrorType.NETWORK_CONNECTION_LOST ||
        errorType == WebResourceErrorType.HOST_LOOKUP ||
        errorType == WebResourceErrorType.CALL_IS_ACTIVE ||
        errorType == WebResourceErrorType.CANNOT_CONNECT_TO_HOST) {
      return {
        'errorType': 'connection',
        'imagePath': 'assets/images/no_connection-error.png',
        'message':
            'Koneksi terputus. Mohon periksa koneksi internet Anda dan coba lagi.',
      }; // Connection-related errors
    } else if (errorType == WebResourceErrorType.BAD_SERVER_RESPONSE ||
        errorType == WebResourceErrorType.FAILED_SSL_HANDSHAKE) {
      return {
        'errorType': 'server',
        'imagePath': 'assets/images/503-error.png',
        'message': 'Kesalahan server. Silakan coba lagi nanti.',
      }; // Server-related errors
    } else if (errorType == WebResourceErrorType.BAD_URL ||
        errorType == WebResourceErrorType.FILE_NOT_FOUND) {
      return {
        'errorType': 'not_found',
        'imagePath': 'assets/images/404-error.png',
        'message': 'Halaman tidak ditemukan.',
      }; // 404-like errors
    } else {
      return {
        'errorType': 'unknown',
        'imagePath': 'assets/images/error.png',
        'message': 'Terjadi kesalahan. Silakan coba lagi nanti.',
      }; // Catch-all for other unknown errors
    }
  }

  // This method filters the HTTP errors based on the status code
  static Map<String, String> filterHttpError(int statusCode) {
    // Log the status code for debugging
    print('ERROR HTTP - STATUS CODE : ${statusCode}');

    if (statusCode == 404) {
      return {
        'errorType': 'not_found',
        'imagePath': 'assets/images/404-error.png',
        'message': 'Halaman tidak ditemukan.',
      }; // 404 Not Found
    } else if (statusCode == 401) {
      return {
        'errorType': 'unauthorized',
        'imagePath': 'assets/images/401-error.png',
        'message': 'Akses tidak sah. Silakan masuk dan coba lagi.',
      }; // 401 Unauthorized
    } else if (statusCode == 403) {
      return {
        'errorType': 'forbidden',
        'imagePath': 'assets/images/403-error.png',
        'message':
            'Akses ditolak. Anda tidak memiliki izin untuk melihat halaman ini.',
      }; // 403 Forbidden
    } else if (statusCode == 429) {
      return {
        'errorType': 'too_many_requests',
        'imagePath': 'assets/images/429-error.png',
        'message': 'Terlalu banyak permintaan. Silakan coba lagi nanti.',
      }; // 429 Too Many Requests
    } else if (statusCode == 400) {
      return {
        'errorType': 'bad_request',
        'imagePath': 'assets/images/400-error.png',
        'message': 'Permintaan tidak valid.',
      }; // 400 Bad Request
    } else if (statusCode == 408 || statusCode == 504) {
      return {
        'errorType': 'timeout',
        'imagePath': 'assets/images/504-error.png',
        'message': 'Waktu permintaan habis. Silakan coba lagi.',
      }; // Timeout errors (408 Request Timeout, 504 Gateway Timeout)
    } else if (statusCode >= 500 && statusCode != 504) {
      return {
        'errorType': 'server',
        'imagePath': 'assets/images/503-error.png',
        'message': 'Kesalahan server. Silakan coba lagi.',
      }; // Server-side errors (500+)
    } else {
      return {
        'errorType': 'unknown',
        'imagePath': 'assets/images/error.png',
        'message': 'Terjadi kesalahan. Silakan coba lagi.',
      }; // Catch-all for other status codes
    }
  }
}
