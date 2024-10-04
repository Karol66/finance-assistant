import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/view/dashboard_view.dart';
import 'package:frontend/view/registration_view.dart';

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

  void login() {
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
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DashboardView(),
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

  Widget socialButton(IconData icon, Color color) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        backgroundColor: Colors.grey.shade200,
        shape: const CircleBorder(),
      ),
      child: FaIcon(icon, size: 30, color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Image.asset(
                'assets/img/test.png',
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
                        fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.subTitle,
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  inputTextField(
                      'Email or Username', false, identifierController),
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
                            onChanged: (bool? newValue) {
                              setState(() {
                                isRemembered = newValue ?? false;
                              });
                            },
                          ),
                          const Text("Remember me"),
                        ],
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          widget.forgotPassword,
                          style: const TextStyle(
                              color: Colors.green, fontWeight: FontWeight.bold),
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
                        backgroundColor: Colors.black,
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
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.black)),
                      const SizedBox(width: 10),
                      const Text('or',
                          style: TextStyle(fontWeight: FontWeight.w400)),
                      const SizedBox(width: 10),
                      Expanded(child: Divider(color: Colors.black)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      socialButton(FontAwesomeIcons.facebookF, Color(0xFF3b5998)),
                      socialButton(FontAwesomeIcons.google, Colors.red),
                      socialButton(FontAwesomeIcons.apple, Colors.black),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?",
                          style: TextStyle(fontSize: 12)),
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
                              color: Colors.green, fontWeight: FontWeight.bold),
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
