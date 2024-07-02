import 'dart:io';

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

  @override
  void initState() {
    super.initState();
    if (widget.page != 0) {
      _currentPageIndex = widget.page;
    }
    welcomeMsg();
    if (Platform.isIOS) {
      debugPrint('Ini IOS');
    } else {
      debugPrint('Ini ANDROID');
    }
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

  List<String> get _appBars => [
        "Home",
        "History",
        "Notification",
        "My Profile",
      ];

  List<Widget> get _pages => [
        const HomePage(),
        History(onGoToHome: _goToHome),
        Notifications(onGoToHome: _goToHome),
        Akunku(onGoToHome: _goToHome),
      ];

  void _goToHome() {
    setState(() {
      _currentPageIndex = 0;
    });
  }

  void _onPageSelected(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InternetAwareWidget(
      child: BlocProvider(
        create: (context) => AuthBloc(databaseRepository: DatabaseRepository())
          ..add(SessionCheck()),
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is SignedIn) {
              return DashboardWidget(
                currentPageIndex: _currentPageIndex,
                onPageSelected: _onPageSelected,
                pages: _pages,
                appBars: _appBars,
              );
            }
            if (state is InRegister) {
              return const Register();
            }
            if (state is UnRegistered) {
              return const GetOtp();
            }
            if (state is FailureLoadState) {
              return Center(
                child: Text(state.message),
              );
            }
            return Container();
          },
        ),
      ),
    );
  }
}
