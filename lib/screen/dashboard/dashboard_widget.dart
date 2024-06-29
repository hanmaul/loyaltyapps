import 'package:flutter/material.dart';
import 'package:loyalty/data/repository/notification_repository.dart';

class DashboardWidget extends StatelessWidget {
  final int currentPageIndex;
  final Function(int) onPageSelected;
  final List<Widget> pages;
  final List<String> appBars;

  const DashboardWidget({
    Key? key,
    required this.currentPageIndex,
    required this.onPageSelected,
    required this.pages,
    required this.appBars,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          appBars[currentPageIndex],
          style: const TextStyle(
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
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: NavigationBar(
          onDestinationSelected: onPageSelected,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          indicatorColor: Colors.transparent,
          selectedIndex: currentPageIndex,
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
                    return const Icon(Icons.notifications_sharp);
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
      body: pages[currentPageIndex],
    );
  }
}
