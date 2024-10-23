import 'package:flutter/material.dart';
import 'package:frontend/services/users_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileManageView extends StatefulWidget {
  const ProfileManageView({super.key});

  @override
  _ProfileManageViewState createState() => _ProfileManageViewState();
}

class _ProfileManageViewState extends State<ProfileManageView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
void initState() {
  super.initState();
  _loadUserData();
}

Future<void> _loadUserData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('jwtToken');

  if (token != null) {
    await _authService.getUserDetail(token);
  
    setState(() {
      _usernameController.text = prefs.getString('username') ?? '';
      _emailController.text = prefs.getString('email') ?? '';
    });
  } else {
    print('Token not found, user not authenticated');
  }
}

  Future<void> _updateProfile() async {
    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    await _authService.updateProfile(username, email, password);

    // Navigator.pop(context, true);
  }

  void _saveProfileData() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: const Text("Passwords do not match!"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    } else {
      _updateProfile();
      Navigator.pop(context);
    }
  }

  Widget inputTextField(
      String hintText, bool obscureText, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF132D46),
      appBar: AppBar(
        title: const Text('Manage Profile'),
        backgroundColor: const Color(0xFF0B6B3A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              inputTextField('Email', false, _emailController),
              const SizedBox(height: 20),
              inputTextField('Username', false, _usernameController),
              const SizedBox(height: 20),
              inputTextField('Password', true, _passwordController),
              const SizedBox(height: 20),
              inputTextField(
                  'Confirm Password', true, _confirmPasswordController),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfileData,
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size.fromHeight(58),
                    backgroundColor: const Color(0xFF01C38D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Save Profile',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
