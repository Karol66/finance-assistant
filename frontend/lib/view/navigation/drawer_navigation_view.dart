import 'package:flutter/material.dart';
import 'package:frontend/services/users_service.dart';
import 'package:frontend/view/accounts/accounts_view.dart';
import 'package:frontend/view/categories/categories_view.dart';
import 'package:frontend/view/dashboard_view.dart';
import 'package:frontend/view/goals/goals_view.dart';
import 'package:frontend/view/notifications/notifications_view.dart';
import 'package:frontend/view/regular_transfers/regular_transfers_view.dart';
import 'package:frontend/view/users/login_view.dart';
import 'package:frontend/view/users/settings_view.dart';
import 'package:frontend/view/statistic/statistic_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawerNavigationController extends StatefulWidget {
  const DrawerNavigationController({super.key});

  @override
  State<DrawerNavigationController> createState() =>
      _DrawerNavigationControllerState();
}

class _DrawerNavigationControllerState
    extends State<DrawerNavigationController> {
  int _selectedIndex = 0;
  String _username = 'Loading...';
  String _email = 'Loading...';

  static final List<Widget> _widgetOptions = <Widget>[
    const DashboardView(),
    const AccountView(),
    const GoalsView(),
    const StatisticView(),
    const CategoriesView(),
    const RegularTransfersView(),
    const NotificationsView(),
    const SettingsView(),
  ];

  static final List<String> _viewTitles = <String>[
    'Dashboard',
    'Accounts',
    'Goals',
    'Statistic',
    'Categories',
    'Regular Transfers',
    'Notifications',
    'Settings',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData(); 
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token != null) {
      await AuthService().getUserDetail(token);

      setState(() {
        _username = prefs.getString('username') ?? 'Unknown User';
        _email = prefs.getString('email') ?? 'Unknown Email';
      });
    } else {
      print('No JWT token found');
    }
  }

  void _logout() async {
    await AuthService().logout();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginView(),
      ),
    );
  }

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
        backgroundColor: const Color(0xFF0B6B3A),
      ),
      drawer: Drawer(
        child: Container(
          color: const Color(0xFF191E29),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text(_username),
                accountEmail: Text(_email),
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
                decoration: const BoxDecoration(
                  color: Color(0xFF0B6B3A),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.dashboard, color: Color(0xFFFFFFFF)),
                title: const Text('Dashboard',
                    style: TextStyle(color: Color(0xFFFFFFFF))),
                onTap: () => _onItemTapped(0),
              ),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet,
                    color: Color(0xFFFFFFFF)),
                title: const Text('Accounts',
                    style: TextStyle(color: Color(0xFFFFFFFF))),
                onTap: () => _onItemTapped(1),
              ),
              ListTile(
                leading:
                    const Icon(Icons.emoji_events, color: Color(0xFFFFFFFF)),
                title: const Text('Goals',
                    style: TextStyle(color: Color(0xFFFFFFFF))),
                onTap: () => _onItemTapped(2),
              ),
              ListTile(
                leading: const Icon(Icons.bar_chart, color: Color(0xFFFFFFFF)),
                title: const Text('Statistic',
                    style: TextStyle(color: Color(0xFFFFFFFF))),
                onTap: () => _onItemTapped(3),
              ),
              ListTile(
                leading: const Icon(Icons.grid_view, color: Color(0xFFFFFFFF)),
                title: const Text('Categories',
                    style: TextStyle(color: Color(0xFFFFFFFF))),
                onTap: () => _onItemTapped(4),
              ),
              ListTile(
                leading:
                    const Icon(Icons.attach_money, color: Color(0xFFFFFFFF)),
                title: const Text('Regular transfers',
                    style: TextStyle(color: Color(0xFFFFFFFF))),
                onTap: () => _onItemTapped(5),
              ),
              ListTile(
                leading:
                    const Icon(Icons.notifications, color: Color(0xFFFFFFFF)),
                title: const Text('Notifications',
                    style: TextStyle(color: Color(0xFFFFFFFF))),
                onTap: () => _onItemTapped(6),
              ),
              ListTile(
                leading: const Icon(Icons.settings, color: Color(0xFFFFFFFF)),
                title: const Text('Settings',
                    style: TextStyle(color: Color(0xFFFFFFFF))),
                onTap: () => _onItemTapped(7),
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Color(0xFFFFFFFF)),
                title: const Text('Logout',
                    style: TextStyle(color: Color(0xFFFFFFFF))),
                onTap: _logout, 
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
    );
  }
}
