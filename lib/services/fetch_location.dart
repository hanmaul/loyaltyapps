// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:loyalty/components/alert.dart';
//
// class FetchLocation {
//   Future<bool> requestLocationPermission(BuildContext context) async {
//     // Request location permission
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//     }
//
//     // If permission is denied forever, show a dialog to guide the user
//     if (permission == LocationPermission.deniedForever) {
//       _showDeniedForeverDialog(context);
//       return false;
//     }
//
//     if (permission == LocationPermission.denied) {
//       // Show a dialog if the permission was denied and not resolved
//       _showGPSDialog(context);
//       return false;
//     }
//
//     return true;
//   }
//
//   Future<bool> checkLocationService() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     return serviceEnabled;
//   }
//
//   // This method will handle validation of GPS and permissions.
//   Future<bool> validateGPSAndPermissions(BuildContext context) async {
//     bool gpsEnabled = await Geolocator.isLocationServiceEnabled();
//     LocationPermission permission = await Geolocator.checkPermission();
//
//     // If GPS is not enabled or permission is denied, show a dialog
//     if (!gpsEnabled || permission == LocationPermission.denied) {
//       _showGPSDialog(context);
//       return false; // Validation failed
//     } else if (permission == LocationPermission.deniedForever) {
//       // Handle the case where permission is denied forever
//       _showDeniedForeverDialog(context);
//       return false; // Validation failed
//     }
//
//     return true; // Validation passed
//   }
//
//   // Show a dialog to prompt the user to enable GPS and allow location permission
//   void _showGPSDialog(BuildContext context) {
//     showAlert(
//       context: context,
//       title: 'Diperlukan GPS',
//       content:
//           'Untuk mengakses layanan ini, harap aktifkan GPS dan izinkan akses lokasi.',
//       type: 'error',
//       actions: [
//         TextButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//             Geolocator.openLocationSettings().then((_) {
//               // Optionally, recheck GPS and permissions here if needed
//             });
//           },
//           child: const Text('Aktifkan'),
//         ),
//       ],
//     );
//   }
//
//   // Show a dialog to notify the user that location permission is denied forever
//   void _showDeniedForeverDialog(BuildContext context) {
//     showAlert(
//       context: context,
//       title: 'Diperlukan Izin Lokasi',
//       content:
//           'Izin akses lokasi telah ditolak secara permanen. Harap izinkan akses lokasi dari pengaturan aplikasi.',
//       type: 'error',
//       actions: [
//         TextButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//             Geolocator.openAppSettings();
//           },
//           child: const Text('Buka Pengaturan'),
//         ),
//       ],
//     );
//   }
//
//   // Function to fetch the current location and return latitude and longitude separately
//   Future<Map<String, double>> getCurrentPosition() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       await Geolocator.openLocationSettings();
//       serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     }
//
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.deniedForever ||
//           permission == LocationPermission.denied) {
//         throw Exception('Location permission denied');
//       }
//     }
//
//     // Get the current position
//     Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//
//     // Return latitude and longitude as a Map
//     return {
//       'latitude': position.latitude,
//       'longitude': position.longitude,
//     };
//   }
// }

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loyalty/components/alert.dart';
import 'dart:io';

class FetchLocation {
  Future<bool> requestLocationPermission(BuildContext context) async {
    // Request location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // If permission is denied forever, show a dialog to guide the user
    if (permission == LocationPermission.deniedForever) {
      _showDeniedForeverDialog(context);
      return false;
    }

    if (permission == LocationPermission.denied) {
      // Show a dialog if the permission was denied and not resolved
      _showGPSDialog(context);
      return false;
    }

    return true;
  }

  // Ensures precise location access, especially for Android 12+ and iOS 14+
  Future<bool> ensurePreciseLocation(BuildContext context) async {
    if (Platform.isAndroid) {
      // For Android 12+, check if precise location is enabled
      LocationAccuracyStatus accuracyStatus =
          await Geolocator.getLocationAccuracy();
      if (accuracyStatus == LocationAccuracyStatus.reduced) {
        // Prompt the user to enable precise location
        _showPreciseLocationDialog(context);
        return false;
      }
    } else if (Platform.isIOS) {
      // For iOS 14+, request temporary full accuracy if only approximate location is granted
      LocationAccuracyStatus accuracyStatus =
          await Geolocator.getLocationAccuracy();
      if (accuracyStatus == LocationAccuracyStatus.reduced) {
        // Request temporary precise location access
        accuracyStatus = await Geolocator.requestTemporaryFullAccuracy(
            purposeKey: "UploadPhoto");
        if (accuracyStatus != LocationAccuracyStatus.precise) {
          return false;
        }
      }
    }
    return true;
  }

  // Validates both GPS and permissions, ensuring precise location
  Future<bool> validateGPSAndPermissions(BuildContext context) async {
    bool gpsEnabled = await Geolocator.isLocationServiceEnabled();
    if (!gpsEnabled) {
      _showGPSDialog(context);
      return false;
    }

    if (!await requestLocationPermission(context)) {
      return false;
    }

    // Ensure precise location is enabled for Android 12+ or iOS 14+
    if (!await ensurePreciseLocation(context)) {
      return false;
    }

    return true;
  }

  // Show a dialog prompting the user to enable precise location in settings (for Android)
  void _showPreciseLocationDialog(BuildContext context) {
    showAlert(
      context: context,
      title: 'Aktifkan Lokasi Presisi',
      content:
          'Fitur ini memerlukan akses lokasi presisi. Silakan aktifkan lokasi presisi di pengaturan aplikasi untuk penandaan yang akurat.',
      type: 'error',
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            Geolocator.openAppSettings();
          },
          child: const Text('Pengaturan'),
        ),
      ],
    );
  }

  // Show a dialog to prompt the user to enable GPS and allow location permission
  void _showGPSDialog(BuildContext context) {
    showAlert(
      context: context,
      title: 'Diperlukan GPS',
      content:
          'Harap aktifkan GPS dan izinkan akses lokasi presisi untuk menggunakan layanan ini.',
      type: 'error',
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            Geolocator.openLocationSettings();
          },
          child: const Text('Aktifkan'),
        ),
      ],
    );
  }

  // Show a dialog to notify the user that location permission is denied permanently
  void _showDeniedForeverDialog(BuildContext context) {
    showAlert(
      context: context,
      title: 'Diperlukan Izin Lokasi',
      content:
          'Akses lokasi telah ditolak. Izinkan akses lokasi presisi untuk menggunakan menu ini.',
      type: 'error',
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            Geolocator.openAppSettings();
          },
          child: const Text('Pengaturan'),
        ),
      ],
    );
  }

  // Function to fetch the current location and ensure it is precise
  Future<Map<String, double>> getCurrentPosition(BuildContext context) async {
    // Ensure GPS, permissions, and precise location are validated
    if (!await validateGPSAndPermissions(context)) {
      throw Exception('Failed to obtain precise location');
    }

    // Fetch the current position with high accuracy
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Return latitude and longitude as a Map
    return {
      'latitude': position.latitude,
      'longitude': position.longitude,
    };
  }
}
