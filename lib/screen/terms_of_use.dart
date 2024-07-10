import 'package:flutter/material.dart';
import 'package:loyalty/data/repository/database_repository.dart';
import 'package:loyalty/screen/dashboard/dashboard.dart';
import 'package:loyalty/screen/response/no_internet_page.dart';
import 'package:loyalty/screen/webview/register.dart';
import 'package:loyalty/services/terms_of_use.dart';

class TermsOfUse extends StatefulWidget {
  final Map<String, dynamic> data;
  const TermsOfUse({super.key, required this.data});

  @override
  State<TermsOfUse> createState() => _TermsOfUseState();
}

class _TermsOfUseState extends State<TermsOfUse> {
  final TermsService termsService = TermsService();
  final DatabaseRepository databaseRepository = DatabaseRepository();

  Future<void> agree() async {
    await databaseRepository.saveUser(userData: widget.data, newDevice: true);
    await termsService.agreeTerms();
    await nextPage();
  }

  Future<void> nextPage() async {
    String nama = await databaseRepository.loadUser(field: 'nama');
    if (nama != "") {
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
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xff0B60B0),
        ),
        body: FutureBuilder<Map<String, dynamic>>(
          future: termsService.listTerms(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData ||
                snapshot.data!['term'] == 'failed') {
              return const Center(child: Text('No terms available'));
            } else {
              final terms = snapshot.data!['term'];
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(terms),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await agree();
                      },
                      child: const Text('Setuju'),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
