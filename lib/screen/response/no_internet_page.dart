import 'dart:async';

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loyalty/bloc/auth/auth_bloc.dart';
import 'package:loyalty/services/auth_service.dart';
import 'package:loyalty/services/internet_service.dart';

class InternetAwareWidget extends StatefulWidget {
  final Widget child;
  final bool byPass;
  final bool checkKey;
  final VoidCallback? onInternetAccessRestored;
  const InternetAwareWidget({
    Key? key,
    required this.child,
    this.byPass = false,
    this.checkKey = false,
    this.onInternetAccessRestored,
  }) : super(key: key);

  @override
  _InternetAwareWidgetState createState() => _InternetAwareWidgetState();
}

class _InternetAwareWidgetState extends State<InternetAwareWidget> {
  bool _isOnline = true;
  bool _wasOffline = false;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  final InternetService _internetService = InternetService();

  @override
  void initState() {
    super.initState();

    // Listen to connectivity changes (Wi-Fi, mobile data, etc.)
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);

    // Check for internet access at initialization and update state
    Connectivity().checkConnectivity().then((result) {
      _updateConnectionStatus(result);
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  // This function updates the state based on connectivity and internet access
  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    bool hasInternet = false;

    if (result != ConnectivityResult.none) {
      hasInternet = await _checkInternetAccess();
    }

    if (hasInternet && _wasOffline) {
      // Trigger the callback when internet access is restored
      widget.onInternetAccessRestored?.call();
      _wasOffline = false; // Reset the flag after internet is restored
    }

    if (!hasInternet) {
      _wasOffline = true; // Set the flag when offline
    }

    // Set state once to update online status
    setState(() => _isOnline = hasInternet);
  }

  // Function to check if the device has real internet access
  Future<bool> _checkInternetAccess() async {
    bool hasInternet = await _internetService.hasActiveInternetConnection();

    if (hasInternet && widget.checkKey) {
      // Ensure the widget is still mounted before using context
      if (!mounted) return false;

      // Call the logoutByKey here with the current context
      await AuthService.logoutByKey(context);
    }

    return hasInternet;
  }

  @override
  Widget build(BuildContext context) {
    return (_isOnline || widget.byPass) ? widget.child : const NoInternet();
  }
}

class NoInternet extends StatelessWidget {
  const NoInternet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(50),
                child: Image.asset(
                  'assets/images/no_connection-error.png',
                  fit: BoxFit.cover,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 24.0), // Added horizontal padding
                child: Text(
                  'Tidak ada koneksi internet.',
                  textAlign: TextAlign.center, // Center the text
                  style: TextStyle(fontSize: 14.0), // Optional: Set font size
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // You can retry the connection or reload the app here
                  BlocProvider.of<AuthBloc>(context).add(SessionCheck());
                },
                child: const Text("Coba Lagi"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
