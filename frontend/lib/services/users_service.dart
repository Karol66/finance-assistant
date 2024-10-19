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

      // Po zalogowaniu pobierz szczegóły użytkownika
      await getUserDetail(data['access']);
      
      print('Login successful, JWT saved and user details fetched');
      return data;
    } else {
      print('Login failed: ${response.body}');
      return null;
    }
  }

  // Pobieranie szczegółów użytkownika po zalogowaniu
  Future<void> getUserDetail(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final response = await http.get(
      Uri.parse('$baseUrl/user_detail/'),  // Endpoint do pobierania danych użytkownika
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',  // Token JWT w nagłówku
      },
    );

    print('Response body: ${response.body}'); 

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);

      // Zapisz dane użytkownika w SharedPreferences
      await prefs.setString('username', data['username']); // Zapisz username
      await prefs.setString('email', data['email']); // Zapisz email

      print('User details fetched successfully');
    } else {
      print('Failed to fetch user details: ${response.body}');
    }
  }

  // Funkcja do wylogowania użytkownika (usunięcie tokenu i danych użytkownika)
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwtToken');  // Usuń token access
    await prefs.remove('refreshToken');  // Usuń token refresh
    await prefs.remove('username');  // Usuń dane użytkownika
    await prefs.remove('email');  // Usuń email użytkownika

    print('User logged out, JWT and user data removed');
  }
}
