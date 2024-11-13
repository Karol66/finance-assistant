import 'package:flutter/material.dart';
import 'package:frontend/view/navigation/drawer_navigation_view.dart';
import 'package:frontend/view/users/password_change_view.dart';
import 'package:frontend/view/users/registration_view.dart';
import 'package:frontend/services/users_service.dart';

class UserWidget extends StatefulWidget {
  final String title;
  final String subTitle;
  final String btnName;
  final String link;
  final String forgotPassword;
  final VoidCallback navigateToRegistration;

  const UserWidget({
    super.key,
    required this.title,
    required this.subTitle,
    required this.btnName,
    required this.link,
    required this.forgotPassword,
    required this.navigateToRegistration,
  });

  @override
  _UserWidgetState createState() => _UserWidgetState();
}

class _UserWidgetState extends State<UserWidget> {
  final TextEditingController identifierController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isRemembered = false;

  final AuthService _authService = AuthService();

  void login() async {
    final identifier = identifierController.text;
    final password = passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Please fill in all fields'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    final response = await _authService.login(identifier, password);
    if (response != null) {
      final accessToken = response['access'];
      final refreshToken = response['refresh'];

      print('Access Token: $accessToken');
      print('Refresh Token: $refreshToken');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DrawerNavigationController(),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login failed'),
          content: const Text('Invalid username or password'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Widget inputTextField(
      String text, bool hide, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: hide,
      decoration: InputDecoration(
        hintText: text,
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
      backgroundColor: const Color(0xFF0B6B3A),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Image.asset(
                'assets/img/logo.png',
                height: 150,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.subTitle,
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  inputTextField('Username', false, identifierController),
                  const SizedBox(height: 10),
                  inputTextField('Password', true, passwordController),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: isRemembered,
                            activeColor: Colors.orange,
                            checkColor: Colors.white,
                            onChanged: (bool? newValue) {
                              setState(() {
                                isRemembered = newValue ?? false;
                              });
                            },
                          ),
                          const Text(
                            "Remember me",
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ChangePasswordView(),
                            ),
                          );
                        },
                        child: Text(
                          widget.forgotPassword,
                          style: const TextStyle(
                              fontSize: 15,
                              color: Colors.orange,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: login,
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size.fromHeight(58),
                        backgroundColor: const Color(0xFF191E29),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        widget.btnName,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Row(
                    children: [
                      Expanded(child: Divider(color: Colors.white)),
                      SizedBox(width: 10),
                      Text(
                        'or',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      SizedBox(width: 10),
                      Expanded(child: Divider(color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account?",
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegistrationView(),
                            ),
                          );
                        },
                        child: Text(
                          widget.link,
                          style: const TextStyle(
                              fontSize: 15,
                              color: Colors.orange,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: UserWidget(
        title: 'Welcome!',
        subTitle: 'Enter your account details below',
        btnName: 'Sign In',
        link: 'Sign Up',
        forgotPassword: 'Forgot Password?',
        navigateToRegistration: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RegistrationView(),
            ),
          );
        },
      ),
    );
  }
}
