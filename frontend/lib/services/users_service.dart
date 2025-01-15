import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = 'http://10.0.2.2:8000/api';

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

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwtToken', data['access']);
      await prefs.setString('refreshToken', data['refresh']);

      await getUserDetail(data['access']);

      print('Login successful, JWT saved and user details fetched');
      return data;
    } else {
      print('Login failed: ${response.body}');
      return null;
    }
  }

  Future<void> getUserDetail(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final response = await http.get(
      Uri.parse('$baseUrl/user_detail/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);

      await prefs.setString('username', data['username']);
      await prefs.setString('email', data['email']);

      print('User details fetched successfully');
    } else {
      print('Failed to fetch user details: ${response.body}');
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwtToken');
    await prefs.remove('refreshToken');
    await prefs.remove('username');
    await prefs.remove('email');

    print('User logged out, JWT and user data removed');
  }

  Future<void> updateProfile(
      String username, String email, String? password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token == null) {
      print("User not authenticated");
      return;
    }

    final Map<String, dynamic> body = {
      'username': username,
      'email': email,
    };

    if (password != null && password.isNotEmpty) {
      body['password'] = password;
    }

    final response = await http.put(
      Uri.parse('$baseUrl/update_profile/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      print('Profile updated successfully');
    } else {
      print('Failed to update profile: ${response.body}');
    }
  }

  Future<void> changePassword(String email, String newPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/change_password/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'new_password': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      print('Password changed successfully');
    } else {
      print('Failed to change password: ${response.body}');
    }
  }
}
