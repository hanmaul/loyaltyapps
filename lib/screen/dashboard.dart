import 'package:flutter/material.dart';
import 'package:loyalty/data/repository/preferences_repository.dart';
import 'package:loyalty/screen/home.dart';
import 'package:loyalty/screen/history.dart';
import 'package:loyalty/screen/notifications.dart';
import 'package:loyalty/screen/akunku.dart';
import 'package:loyalty/data/repository/webview_repository.dart';
import 'package:loyalty/data/repository/notification_repository.dart';
import 'package:loyalty/screen/response/no_internet_page.dart';

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
  }

  List<String> get _appBars => [
        "Home",
        "History",
        "Notification",
        "My Profile",
      ];

  List<Widget> get _pages => [
        // Home
        HomePage(),

        // History
        FutureBuilder<String>(
          future: WebviewRepository().getUrlHistory(),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // Show a loading indicator while waiting
            } else if (snapshot.hasError) {
              return Text(
                  'Error: ${snapshot.error}'); // Show error message if something went wrong
            } else {
              return History(url: snapshot.data!);
            }
          },
        ),

        // Notifikasi
        FutureBuilder<String>(
          future: WebviewRepository().getUrlNotifikasi(),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // Show a loading indicator while waiting
            } else if (snapshot.hasError) {
              return Text(
                  'Error: ${snapshot.error}'); // Show error message if something went wrong
            } else {
              return Notifications(url: snapshot.data!);
            }
          },
        ),

        // AKunku
        FutureBuilder<String>(
          future: WebviewRepository().getUrlAkunku(),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // Show a loading indicator while waiting
            } else if (snapshot.hasError) {
              return Text(
                  'Error: ${snapshot.error}'); // Show error message if something went wrong
            } else {
              return Akunku(url: snapshot.data!);
            }
          },
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return InternetAwareWidget(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _appBars[_currentPageIndex],
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xff0B60B0),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: NavigationBar(
            onDestinationSelected: (int index) {
              setState(() {
                _currentPageIndex = index;
              });
            },
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            indicatorColor: Colors.transparent,
            selectedIndex: _currentPageIndex,
            destinations: <Widget>[
              const NavigationDestination(
                selectedIcon: Icon(
                  Icons.home,
                  color: Color(0xff0B60B0),
                ),
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              const NavigationDestination(
                selectedIcon: Icon(
                  Icons.history_sharp,
                  color: Color(0xff0B60B0),
                ),
                icon: Icon(Icons.history_outlined),
                label: 'History',
              ),
              NavigationDestination(
                selectedIcon: const Icon(
                  Icons.notifications_sharp,
                  color: Color(0xff0B60B0),
                ),
                icon: FutureBuilder<int>(
                  future: NotifRepository().getUnread(),
                  builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting ||
                        snapshot.hasError ||
                        snapshot.data == 0) {
                      return const Icon(Icons
                          .notifications_sharp); // Show a loading indicator while waiting
                    } else {
                      return Badge(
                        label: Text('${snapshot.data}'),
                        child: const Icon(Icons.notifications_sharp),
                      );
                    }
                  },
                ),
                label: 'Notification',
              ),
              const NavigationDestination(
                selectedIcon: Icon(
                  Icons.account_circle,
                  color: Color(0xff0B60B0),
                ),
                icon: Icon(Icons.account_circle),
                label: 'Me',
              ),
            ],
          ),
        ),
        body: _pages[_currentPageIndex],
      ),
    );
  }
}
