import 'package:flutter/material.dart';
import 'package:frontend/services/users_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileManageView extends StatefulWidget {
  const ProfileManageView({super.key});

  @override
  _ProfileManageViewState createState() => _ProfileManageViewState();
}

class _ProfileManageViewState extends State<ProfileManageView> {
  final _formKey = GlobalKey<FormState>();
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

    Navigator.pop(context);
  }

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email';
    } else if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? usernameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a username';
    } else if (value.length > 255) {
      return 'Username cannot exceed 255 characters';
    }
    return null;
  }

  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    } else if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    } else if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    } else if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    } else if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  String? confirmPasswordValidator(String? value) {
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Widget inputTextField(String hintText, bool obscureText, TextEditingController controller, String? Function(String?) validator) {
    return TextFormField(
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
        errorStyle: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      validator: validator,
    );
  }

  void _saveProfileData() {
    if (_formKey.currentState!.validate()) {
      _updateProfile();
    }
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                inputTextField('Email', false, _emailController, emailValidator),
                const SizedBox(height: 20),
                inputTextField('Username', false, _usernameController, usernameValidator),
                const SizedBox(height: 20),
                inputTextField('Password', true, _passwordController, passwordValidator),
                const SizedBox(height: 20),
                inputTextField('Confirm Password', true, _confirmPasswordController, confirmPasswordValidator),
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
      ),
    );
  }
}
