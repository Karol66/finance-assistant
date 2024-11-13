import 'package:flutter/material.dart';
import 'package:frontend/view/users/login_view.dart';
import 'package:frontend/services/users_service.dart';

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
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final AuthService authService = AuthService();

  void register() async {
    if (_formKey.currentState!.validate()) {
      final email = emailController.text;
      final username = usernameController.text;
      final password = passwordController.text;

      await authService.register(username, email, password);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginView(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields correctly.")),
      );
    }
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
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Widget inputTextField(
      String text, bool hide, TextEditingController controller, String? Function(String?) validator) {
    return TextFormField(
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
        errorStyle: const TextStyle(
          color: Colors.redAccent, // Ustaw kolor komunikatu błędu na jasnoczerwony
          fontWeight: FontWeight.bold,
        ),
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B6B3A),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
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
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.subTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    inputTextField(
                      'Email',
                      false,
                      emailController,
                      emailValidator,
                    ),
                    const SizedBox(height: 10),
                    inputTextField(
                      'Username',
                      false,
                      usernameController,
                      usernameValidator,
                    ),
                    const SizedBox(height: 10),
                    inputTextField(
                      'Password',
                      true,
                      passwordController,
                      passwordValidator,
                    ),
                    const SizedBox(height: 10),
                    inputTextField(
                      'Confirm Password',
                      true,
                      confirmPasswordController,
                      confirmPasswordValidator,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: register,
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
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      children: [
                        Expanded(child: Divider(color: Colors.white)),
                        SizedBox(width: 10),
                        Text('or',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            )),
                        SizedBox(width: 10),
                        Expanded(child: Divider(color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account?",
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: widget.navigateToLogin,
                          child: Text(
                            widget.link,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
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
