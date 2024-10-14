import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; 

class AuthService {
  final String baseUrl = 'http://10.0.2.2:8000/api';  // Adres API

  // Rejestracja użytkownika
  Future<void> register(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      print('Registration successful');
    } else {
      print('Registration failed: ${response.body}');
    }
  }

  // Logowanie użytkownika
  Future<Map<String, dynamic>?> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);

      // Zapisz token JWT w SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwtToken', data['access']);  // Zapisz token access JWT
      await prefs.setString('refreshToken', data['refresh']);  // Zapisz token refresh JWT

      print('Login successful, JWT saved');
      return data;
    } else {
      print('Login failed: ${response.body}');
      return null;
    }
  }

  // Funkcja do wylogowania użytkownika (usunięcie tokenu z SharedPreferences)
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwtToken');  // Usuń token access
    await prefs.remove('refreshToken');  // Usuń token refresh

    print('User logged out, JWT removed');
  }
}