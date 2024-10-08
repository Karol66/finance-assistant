import 'package:flutter/material.dart';
import 'package:frontend/view/accounts/accounts_view.dart';
import 'package:frontend/view/cards/cards_view.dart';
import 'package:frontend/view/categories/categories_view.dart';
import 'package:frontend/view/dashboard_view.dart';
import 'package:frontend/view/goals/goals_view.dart';
import 'package:frontend/view/notifications/notifications_view.dart';
import 'package:frontend/view/payments/payments_view.dart';
import 'package:frontend/view/users/settings_view.dart';
import 'package:frontend/view/statistic/statistic_view.dart';
import 'package:frontend/view/transfers/transfers_view.dart';

class DrawerNavigationController extends StatefulWidget {
  const DrawerNavigationController({super.key});

  @override
  State<DrawerNavigationController> createState() =>
      _DrawerNavigationControllerState();
}

class _DrawerNavigationControllerState
    extends State<DrawerNavigationController> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    DashboardView(),
    AccountView(),
    TransfersView(),
    GoalsView(),
    StatisticView(),
    CategoriesView(),
    CardsView(),
    RegularPaymentsView(),
    NotificationsView(),
    SettingsView(),
  ];

  static final List<String> _viewTitles = <String>[
    'Dashboard',
    'Accounts',
    'Transfers',
    'Goals',
    'Statistic',
    'Categories',
    'Cards',
    'Regular Payments',
    'Notifications',
    'Settings',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      Navigator.pop(context); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_viewTitles[_selectedIndex]),
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
              leading: const Icon(Icons.sync),
              title: const Text('Transfers'),
              onTap: () => _onItemTapped(2),
            ),
            ListTile(
              leading: const Icon(Icons.emoji_events),
              title: const Text('Goals'),
              onTap: () => _onItemTapped(3),
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Statistic'),
              onTap: () => _onItemTapped(4),
            ),
            ListTile(
              leading: const Icon(Icons.grid_view),
              title: const Text('Categories'),
              onTap: () => _onItemTapped(5),
            ),
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text('Cards'),
              onTap: () => _onItemTapped(6),
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Regular payments'),
              onTap: () => _onItemTapped(7),
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              onTap: () => _onItemTapped(8),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () => _onItemTapped(9),
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
