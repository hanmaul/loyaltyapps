import 'package:flutter/material.dart';
import 'package:loyalty/screen/home.dart';
import 'package:loyalty/screen/notifications.dart';
import 'package:loyalty/screen/webview/akunku.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentPageIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    HomePage(),
    Notifications(),
    Akunku(),
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
          NavigationDestination(
            selectedIcon: Icon(
              Icons.notifications_sharp,
              color: Color(0xff0B60B0),
            ),
            icon: Badge(
              label: Text('2'),
              child: Icon(Icons.notifications_sharp),
            ),
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
