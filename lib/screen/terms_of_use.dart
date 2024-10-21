import 'package:flutter/material.dart';
import 'package:loyalty/data/repository/database_repository.dart';
import 'package:loyalty/screen/dashboard/dashboard.dart';
import 'package:loyalty/screen/response/no_internet_page.dart';
import 'package:loyalty/screen/webview/register.dart';
import 'package:loyalty/services/terms_of_use.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TermsOfUse extends StatefulWidget {
  final Map<String, dynamic> data;
  const TermsOfUse({super.key, required this.data});

  @override
  State<TermsOfUse> createState() => _TermsOfUseState();
}

class _TermsOfUseState extends State<TermsOfUse> {
  late final WebViewController controller;
  final TermsService termsService = TermsService();
  final DatabaseRepository databaseRepository = DatabaseRepository();
  bool isLoading = true;
  bool isAgreeing = false;

  @override
  void initState() {
    super.initState();
    final urlTerms = termsService.getUrlTerms();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {
            setState(() {
              isLoading =
                  true; // Show the loading indicator when page starts loading
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading =
                  false; // Hide the loading indicator when page finishes loading
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              isLoading = false; // Hide the loading indicator on error
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(urlTerms));
  }

  Future<void> agree() async {
    setState(() {
      isAgreeing = true; // Start the loading when the "Agree" button is pressed
    });

    try {
      // 1. Save the user data and ensure it completes before moving forward
      await databaseRepository.saveUser(
          userData: widget.data, newDevice: true, forceLogout: false);

      // 2. Agree to terms after saving user data
      await termsService.agreeTerms();

      // 3. Navigate to the next page after both previous operations complete
      await nextPage(); // Ensure this is awaited
    } catch (e) {
      // Handle potential errors
      debugPrint('Error during agree process: $e');
    } finally {
      setState(() {
        isAgreeing = false; // Stop the loading when the process is done
      });
    }
  }

  Future<void> nextPage() async {
    bool isRegistered = await databaseRepository.isRegistered();
    if (isRegistered) {
      goToDashboard();
    } else {
      goToRegister();
    }
  }

  void goToDashboard() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return const Dashboard(page: 0);
        },
      ),
      (route) => false,
    );
  }

  void goToRegister() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return const Register();
        },
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InternetAwareWidget(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Terms of use",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xff0B60B0),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: controller),
            if (isLoading) // Show the loading indicator if isLoading is true
              const Center(
                child: CircularProgressIndicator(
                  color: Color(0xff0B60B0),
                ),
              ),
            if (isAgreeing) // Show a full-screen loading overlay when "Agree" is pressed
              Container(
                color: Colors.black.withOpacity(0.5), // Transparent overlay
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xff0B60B0),
                  ),
                ),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: isAgreeing // Disable the button if processing
                          ? null
                          : () async {
                              await agree();
                            },
                      child: const Text('Setuju'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
