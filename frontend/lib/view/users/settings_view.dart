import 'package:flutter/material.dart';
import 'package:frontend/view/users/profile_manage_view.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {

  void profileManageClick() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileManageView(),
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
          ],
        ),
      ),
    );
  }
}
