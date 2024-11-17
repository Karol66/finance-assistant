import 'package:flutter/material.dart';
import 'package:frontend/view/users/login_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Inter",
        useMaterial3: false,
      ),
      home: const LoginView(),
    );
  }
}
