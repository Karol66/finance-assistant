import 'package:flutter/material.dart';
import 'package:frontend/view/users/pin_view.dart';
import 'package:frontend/view/users/profile_manage_view.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _notificationsEnabled = true;
  bool _darkTheme = false;
  String _selectedCurrency = 'USD (\$)';

  final List<String> _currencies = [
    'USD (\$)',
    'EUR (€)',
    'GBP (£)',
    'PLN (zł)'
  ];

  void profileManageClick() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileManageView(),
      ),
    );
  }

  void setPinClick() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PinView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF132D46),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const CircleAvatar(
                backgroundImage: AssetImage('assets/img/test.png'),
              ),
              title: const Text(
                'Edit Profile',
                style: TextStyle(color: Color(0xFFFFFFFF)),
              ),
              trailing: IconButton(
                onPressed: profileManageClick,
                icon: const Icon(Icons.arrow_forward_ios),
                color: const Color(0xFFFFFFFF),
                iconSize: 24,
              ),
            ),
            const Divider(color: Color(0xFFFFFFFF)),
            ListTile(
              leading: const Icon(Icons.lock, color: Color(0xFFFFFFFF)),
              title: const Text(
                'Set PIN',
                style: TextStyle(color: Color(0xFFFFFFFF)),
              ),
              trailing: IconButton(
                onPressed: setPinClick,
                icon: const Icon(Icons.arrow_forward_ios),
                color: const Color(0xFFFFFFFF),
                iconSize: 24,
              ),
            ),
            const Divider(color: Color(0xFFFFFFFF)),
            ListTile(
              leading:
                  const Icon(Icons.notifications, color: Color(0xFFFFFFFF)),
              title: const Text(
                'Enable Notifications',
                style: TextStyle(color: Color(0xFFFFFFFF)),
              ),
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
                activeColor: const Color(0xFF01C38D),
                inactiveThumbColor: const Color(0xFFBBBBBB),
                inactiveTrackColor: const Color(0xFF494E59),
              ),
            ),
            const Divider(color: Color(0xFFFFFFFF)),
            ListTile(
              leading: const Icon(Icons.dark_mode, color: Color(0xFFFFFFFF)),
              title: const Text(
                'Dark Theme',
                style: TextStyle(color: Color(0xFFFFFFFF)),
              ),
              trailing: Switch(
                value: _darkTheme,
                onChanged: (bool value) {
                  setState(() {
                    _darkTheme = value;
                  });
                },
                activeColor: const Color(0xFF01C38D),
                inactiveThumbColor: const Color(0xFFBBBBBB),
                inactiveTrackColor: const Color(0xFF494E59),
              ),
            ),
            const Divider(color: Color(0xFFFFFFFF)),
            ListTile(
              leading: const Icon(Icons.attach_money, color: Color(0xFFFFFFFF)),
              title: const Text(
                'Currency',
                style: TextStyle(color: Color(0xFFFFFFFF)),
              ),
              trailing: DropdownButton<String>(
                value: _selectedCurrency,
                dropdownColor: const Color(0xFF132D46),
                items: _currencies.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(color: Color(0xFFFFFFFF)),
                    ),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedCurrency = newValue!;
                  });
                },
              ),
            ),
            const Divider(color: Color(0xFFFFFFFF)),
          ],
        ),
      ),
    );
  }
}
