import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loyalty/bloc/auth/auth_bloc.dart';
import 'package:loyalty/data/repository/database_repository.dart';
import 'package:loyalty/screen/auth/get_otp.dart';
import 'package:loyalty/screen/dashboard/dashboard_widget.dart';
import 'package:loyalty/screen/home.dart';
import 'package:loyalty/screen/history.dart';
import 'package:loyalty/screen/notifications.dart';
import 'package:loyalty/screen/akunku.dart';
import 'package:loyalty/screen/response/no_internet_page.dart';
import 'package:loyalty/screen/webview/register.dart';
import 'package:loyalty/services/auth_service.dart';
import 'package:loyalty/services/internet_service.dart';

class Dashboard extends StatefulWidget {
  final int page;

  const Dashboard({
    super.key,
    required this.page,
  });

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentPageIndex = 0;
  bool _showBackButton = false;
  VoidCallback? _onBackPressed;

  @override
  void initState() {
    super.initState();
    if (widget.page != 0) {
      _currentPageIndex = widget.page;
    }
    welcomeMsg();
  }

  void _updateBackButton(bool show, VoidCallback? onBackPressed) {
    setState(() {
      _showBackButton = show;
      _onBackPressed = onBackPressed;
    });
  }

  List<String> get _appBars => [
        "Home",
        "History",
        "Notification",
        "My Profile",
      ];

  List<Widget> get _pages => [
        const HomePage(),
        History(onGoToHome: _goToHome),
        Notifications(
          onGoToHome: _goToHome,
          updateBackButton: _updateBackButton,
        ),
        Akunku(onGoToHome: _goToHome),
      ];

  void _goToHome() {
    setState(() {
      _currentPageIndex = 0;
      _showBackButton = false;
    });
  }

  void _onPageSelected(int index) {
    setState(() {
      _currentPageIndex = index;
      _showBackButton = false; // Reset back button when changing pages
    });
  }

  @override
  Widget build(BuildContext context) {
    return InternetAwareWidget(
      checkKey: true,
      byPass: true,
      child: BlocProvider(
        create: (context) => AuthBloc(
          databaseRepository: DatabaseRepository(),
          internetService: InternetService(),
        )..add(SessionCheck()),
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is SignedIn) {
              return DashboardWidget(
                currentPageIndex: _currentPageIndex,
                onPageSelected: _onPageSelected,
                pages: _pages,
                appBars: _appBars,
                showBackButton: _showBackButton,
                onBackPressed: _onBackPressed,
              );
            }
            if (state is InRegister) {
              return const Register();
            }
            if (state is UnRegistered) {
              return const GetOtp();
            }
            if (state is UserLoggedOut) {
              AuthService.signOut(context);
            }
            if (state is FailureLoadState) {
              return const NoInternet();
            }
            return Container(
              color: Colors.white, // Set the background color to white
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> welcomeMsg() async {
    DatabaseRepository databaseRepository = DatabaseRepository();

    String first = await databaseRepository.loadUser(field: "firstAccess");
    String key = await databaseRepository.loadUser(field: "key");
    String currentDate = DateTime.now().toString();

    if (first == "" && key != "") {
      String nama = await databaseRepository.loadUser(field: 'nama');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Hai, $nama !",
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 20, left: 30, right: 30),
        ),
      );
      await databaseRepository.updateUser(
          field: "firstAccess", data: currentDate);
    }
  }
}
