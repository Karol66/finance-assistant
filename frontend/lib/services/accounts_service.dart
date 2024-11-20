import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AccountsService {
  final String baseUrl = 'http://10.0.2.2:8000/api';

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwtToken');
  }

  Future<Map<String, dynamic>?> fetchAccounts({int page = 1}) async {
    String? token = await _getToken();

    if (token == null) {
      print("User not authenticated");
      return null;
    }

    String url = '$baseUrl/accounts/?page=$page';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);

      List<dynamic> results = data['results'] ?? [];
      int totalPages = data['total_pages'] ?? 1;

      return {
        'results': results
            .map((account) => {
                  "id": account["id"],
                  "account_name": account["account_name"],
                  "balance": account["balance"],
                  "include_in_total": account["include_in_total"],
                  "account_color": account["account_color"],
                  "account_icon": account["account_icon"],
                })
            .toList(),
        'total_pages': totalPages,
      };
    } else {
      print('Failed to fetch accounts: ${response.body}');
      return null;
    }
  }

  Future<List<dynamic>?> fetchAllAccounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token == null) {
      print("User not authenticated");
      return null;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/accounts/all/'),
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

  Future<void> createAccount(String accountName, String balance,
      String accountColor, String accountIcon) async {
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
        'balance': balance,
        'account_color': accountColor,
        'account_icon': accountIcon,
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
      String balance,
      String accountColor,
      String accountIcon) async {
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
        'balance': balance,
        'account_color': accountColor,
        'account_icon': accountIcon,
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

  Future<double?> fetchTotalAccountBalance() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token == null) {
      print("User not authenticated");
      return null;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/accounts/total-balance/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      return data['total_balance']?.toDouble();
    } else {
      print('Failed to fetch total account balance: ${response.body}');
      return null;
    }
  }
}
