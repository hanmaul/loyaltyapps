import 'package:flutter/material.dart';
import 'package:loyalty/screen/home.dart';
import 'package:loyalty/screen/notifications.dart';
import 'package:loyalty/screen/history.dart';
import 'package:loyalty/screen/webview/akunku.dart';
import 'package:loyalty/data/repository/webview_repository.dart';

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

  List<Widget> get _pages => [
        // Home
        HomePage(),

        // History
        History(),

        // Notifikasi
        Notifications(),

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
              return Akunku(
                  url: snapshot
                      .data!); // Create Akunku widget with the fetched URL
            }
          },
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        backgroundColor: Colors.white,
        indicatorColor: Colors.transparent,
        selectedIndex: _currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(
              Icons.home,
              color: Color(0xff0B60B0),
            ),
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.history_sharp,
              color: Color(0xff0B60B0),
            ),
            icon: Icon(Icons.history_outlined),
            label: 'History',
          ),
          // NavigationDestination(
          //   selectedIcon: Icon(
          //     Icons.notifications_sharp,
          //     color: Color(0xff0B60B0),
          //   ),
          //   icon: Badge(
          //     label: Text('2'),
          //     child: Icon(Icons.notifications_sharp),
          //   ),
          //   label: 'Notifications',
          // ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.notifications_sharp,
              color: Color(0xff0B60B0),
            ),
            icon: Icon(Icons.notifications_sharp),
            label: 'Notifications',
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.account_circle,
              color: Color(0xff0B60B0),
            ),
            icon: Icon(Icons.account_circle),
            label: 'Me',
          ),
        ],
      ),
      body: _pages[_currentPageIndex],
    );
  }
}
