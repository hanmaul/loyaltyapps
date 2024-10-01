import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loyalty/components/alert.dart';

class FetchLocation {
  Future<bool> requestLocationPermission(BuildContext context) async {
    // Check if GPS is enabled
    // bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    // if (!serviceEnabled) {
    //   await Geolocator.openLocationSettings();
    //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
    // }

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

  /// Ensures that location permission is granted
  Future<bool> _ensureLocationPermissionGranted(BuildContext context) async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permission denied, return false
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showDeniedForeverDialog(context);
      return false;
    }

    return true;
  }

  /// Opens location settings and returns true when the service is enabled
  Future<bool> _ensureLocationServiceEnabled() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
    }

    return serviceEnabled;
  }

  Future<bool> checkLocationService() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    return serviceEnabled;
  }

// This method will handle validation of GPS and permissions.
  Future<bool> validateGPSAndPermissions(BuildContext context) async {
    bool gpsEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();

    // If GPS is not enabled or permission is denied, show a dialog
    if (!gpsEnabled || permission == LocationPermission.denied) {
      _showGPSDialog(context);
      return false; // Validation failed
    } else if (permission == LocationPermission.deniedForever) {
      // Handle the case where permission is denied forever
      _showDeniedForeverDialog(context);
      return false; // Validation failed
    }

    return true; // Validation passed
  }

  // Show a dialog to prompt the user to enable GPS and allow location permission
  void _showGPSDialog(BuildContext context) {
    showAlert(
      context: context,
      title: 'Diperlukan GPS',
      content:
          'Untuk mengakses layanan ini, harap aktifkan GPS dan izinkan akses lokasi.',
      type: 'error',
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            Geolocator.openLocationSettings().then((_) {
              // Optionally, recheck GPS and permissions here if needed
            });
          },
          child: const Text('Aktifkan'),
        ),
      ],
    );
  }

  // Show a dialog to notify the user that location permission is denied forever
  void _showDeniedForeverDialog(BuildContext context) {
    showAlert(
      context: context,
      title: 'Diperlukan Izin Lokasi',
      content:
          'Izin akses lokasi telah ditolak secara permanen. Harap izinkan akses lokasi dari pengaturan aplikasi.',
      type: 'error',
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            Geolocator.openAppSettings();
          },
          child: const Text('Buka Pengaturan'),
        ),
      ],
    );
  }

  // Function to fetch the current location and return latitude and longitude separately
  Future<Map<String, double>> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }

    // Get the current position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Return latitude and longitude as a Map
    return {
      'latitude': position.latitude,
      'longitude': position.longitude,
    };
  }
}
