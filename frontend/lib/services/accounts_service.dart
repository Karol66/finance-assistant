import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AccountsService {
  final String baseUrl = 'http://10.0.2.2:8000/api';

  Future<List<dynamic>?> fetchAccounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token == null) {
      print("User not authenticated");
      return null;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/accounts/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to fetch accounts: ${response.body}');
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchAccountById(int accountId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token == null) {
      print("User not authenticated");
      return null;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/accounts/$accountId/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to fetch account: ${response.body}');
      return null;
    }
  }

  Future<void> createAccount(
      String accountName,
      String accountType,
      String balance,
      String currency,
      String accountColor,
      String accountIcon,
      String accountNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token == null) {
      print("User not authenticated");
      return;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/accounts/create/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'account_name': accountName,
        'account_type': accountType,
        'balance': balance,
        'currency': currency,
        'account_color': accountColor,
        'account_icon': accountIcon,
        'account_number': accountNumber,
      }),
    );

    if (response.statusCode == 201) {
      print('Account created successfully');
    } else {
      print('Failed to create account: ${response.body}');
    }
  }

  Future<void> updateAccount(
      int accountId,
      String accountName,
      String accountType,
      String balance,
      String currency,
      String accountColor,
      String accountIcon,
      String accountNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token == null) {
      print("User not authenticated");
      return;
    }

    final response = await http.put(
      Uri.parse('$baseUrl/accounts/$accountId/edit/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'account_name': accountName,
        'account_type': accountType,
        'balance': balance,
        'currency': currency,
        'account_color': accountColor,
        'account_icon': accountIcon,
        'account_number': accountNumber,
      }),
    );

    if (response.statusCode == 200) {
      print('Account updated successfully');
    } else {
      print('Failed to update account: ${response.body}');
    }
  }

  Future<void> deleteAccount(int accountId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token == null) {
      print("User not authenticated");
      return;
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/accounts/$accountId/delete/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 204) {
      print('Account soft-deleted successfully');
    } else {
      print('Failed to delete account: ${response.body}');
    }
  }
}
