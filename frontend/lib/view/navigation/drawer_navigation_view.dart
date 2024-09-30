import 'package:flutter/material.dart';
import 'package:frontend/view/accounts_view.dart';
import 'package:frontend/view/cards_view.dart';
import 'package:frontend/view/categories_view.dart';
import 'package:frontend/view/dashboard_view.dart';
import 'package:frontend/view/notifications_view.dart';
import 'package:frontend/view/regular_payments_view.dart';
import 'package:frontend/view/settings_view.dart';
import 'package:frontend/view/statistic_view.dart';


class DrawerNavigationController extends StatefulWidget {
  const DrawerNavigationController({super.key});

  @override
  State<DrawerNavigationController> createState() =>
      _DrawerNavigationControllerState();
}

class _DrawerNavigationControllerState
    extends State<DrawerNavigationController> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    DashboardView(),
    AccountView(),
    StatisticView(),
    CategoriesView(),
    CardsView(),
    RegularPaymentsView(),
    NotificationsView(),
    SettingsView()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      Navigator.pop(context); // Zamknij szufladę po wyborze
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moja Aplikacja'),
        backgroundColor: const Color.fromARGB(255, 0, 141, 73),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: const Text("Test"),
              accountEmail: const Text("Test@Test"),
              currentAccountPicture: CircleAvatar(
                child: ClipOval(
                  child: Image.asset(
                    'assets/img/test.png',
                    fit: BoxFit.cover,
                    width: 90,
                    height: 90,
                  ),
                ),
              ),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 0, 141, 73),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('Accounts'),
              onTap: () => _onItemTapped(1),
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Statistic'),
              onTap: () => _onItemTapped(2),
            ),
            ListTile(
              leading: const Icon(Icons.grid_view),
              title: const Text('Categories'),
              onTap: () => _onItemTapped(3),
            ),
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text('Cards'),
              onTap: () => _onItemTapped(4),
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Regular payments'),
              onTap: () => _onItemTapped(5),
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              onTap: () => _onItemTapped(6),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () => _onItemTapped(7),
            ),
          ],
        ),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
    );
  }
}
