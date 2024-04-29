import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class InternetAwareWidget extends StatefulWidget {
  final Widget child;
  const InternetAwareWidget({Key? key, required this.child}) : super(key: key);

  @override
  _InternetAwareWidgetState createState() => _InternetAwareWidgetState();
}

class _InternetAwareWidgetState extends State<InternetAwareWidget> {
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _checkInternetConnectivity();
  }

  Future<void> _checkInternetConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) {
      setState(() => _isOnline = false);
    } else {
      setState(() => _isOnline = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isOnline ? widget.child : const NoInternet();
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
                padding: EdgeInsets.only(
                    top: 50.0, left: 50.0, right: 50.0, bottom: 50.0),
                child: Image.asset(
                  'assets/images/No connection-rafiki.png',
                  fit: BoxFit.cover,
                ),
              ),
              Text('No Internet Connection..'),
              SizedBox(height: 20), // Add some space before the button
              ElevatedButton(
                onPressed: () => _retryInternetConnection(context),
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _retryInternetConnection(BuildContext context) {
    // You can use a function like this to retry the connection
    // This assumes your InternetAwareWidget is above this in the widget tree
    var internetAwareWidgetState =
        context.findAncestorStateOfType<_InternetAwareWidgetState>();
    internetAwareWidgetState?._checkInternetConnectivity();
  }
}
