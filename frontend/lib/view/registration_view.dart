import 'package:flutter/material.dart';
import 'package:frontend/view/login_view.dart';

class RegistrationWidget extends StatefulWidget {
  final String title;
  final String subTitle;
  final String btnName;
  final String link;
  final VoidCallback navigateToLogin;

  const RegistrationWidget({
    super.key,
    required this.title,
    required this.subTitle,
    required this.btnName,
    required this.link,
    required this.navigateToLogin,
  });

  @override
  _RegistrationWidgetState createState() => _RegistrationWidgetState();
}

class _RegistrationWidgetState extends State<RegistrationWidget> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  void register() {
    final email = emailController.text;
    final username = usernameController.text;
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (email.isEmpty || username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
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
    } else if (password != confirmPassword) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Passwords do not match'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      Navigator.pushNamed(context, '/login');
    }
  }

  Widget inputTextField(String text, bool hide, TextEditingController controller) {
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
    return SingleChildScrollView( 
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
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  widget.subTitle,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                inputTextField('Email', false, emailController),
                const SizedBox(height: 10),
                inputTextField('Username', false, usernameController),
                const SizedBox(height: 10),
                inputTextField('Password', true, passwordController),
                const SizedBox(height: 10),
                inputTextField('Confirm Password', true, confirmPasswordController),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity, 
                  child: ElevatedButton(
                    onPressed: register,
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
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.black)),
                    const SizedBox(width: 10),
                    const Text('or', style: TextStyle(fontWeight: FontWeight.w400)),
                    const SizedBox(width: 10),
                    Expanded(child: Divider(color: Colors.black)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?", style: TextStyle(fontSize: 12)),
                    TextButton(
                      onPressed: widget.navigateToLogin,
                      child: Text(
                        widget.link,
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RegistrationView extends StatelessWidget {
  const RegistrationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RegistrationWidget(
        title: 'Registration',
        subTitle: 'Register your data below',
        btnName: 'Register',
        link: 'Log In',
        navigateToLogin: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginView(),
            ),
          );
        },
      ),
    );
  }
}
