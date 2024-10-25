import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TransfersService {
  final String baseUrl = 'http://10.0.2.2:8000/api';

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwtToken');
  }

  Future<List<dynamic>?> fetchTransfers() async {
    String? token = await _getToken();

    if (token == null) {
      print("User not authenticated");
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transfers/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to fetch transfers: ${response.body}');
        return null;
      }
    } catch (error) {
      print('Error fetching transfers: $error');
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchTransferById(int transferId) async {
    String? token = await _getToken();

    if (token == null) {
      print("User not authenticated");
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transfers/$transferId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to fetch transfer: ${response.body}');
        return null;
      }
    } catch (error) {
      print('Error fetching transfer: $error');
      return null;
    }
  }

  Future<void> createTransfer(String transferName, String amount,
      String description, String date, int accountId, int categoryId,
      {bool isRegular = false, String interval = ''}) async {
    String? token = await _getToken();

    if (token == null) {
      print("User not authenticated");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/transfers/create/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'transfer_name': transferName,
          'amount': amount,
          'description': description,
          'date': date,
          'account': accountId,
          'category': categoryId,
          'is_regular': isRegular,
          'interval': interval,
        }),
      );

      if (response.statusCode == 201) {
        print('Transfer created successfully');
      } else {
        print('Failed to create transfer: ${response.body}');
      }
    } catch (error) {
      print('Error creating transfer: $error');
    }
  }

  Future<void> updateTransfer(
      int transferId,
      String transferName,
      String amount,
      String description,
      String date,
      int accountId,
      int categoryId,
      {bool isRegular = false,
      String interval = ''}) async {
    String? token = await _getToken();

    if (token == null) {
      print("User not authenticated");
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/transfers/$transferId/edit/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'transfer_name': transferName,
          'amount': amount,
          'description': description,
          'date': date,
          'account': accountId,
          'category': categoryId,
          'is_regular': isRegular,
          'interval': interval,
        }),
      );

      if (response.statusCode == 200) {
        print('Transfer updated successfully');
      } else {
        print('Failed to update transfer: ${response.body}');
      }
    } catch (error) {
      print('Error updating transfer: $error');
    }
  }

  Future<void> deleteTransfer(int transferId) async {
    String? token = await _getToken();

    if (token == null) {
      print("User not authenticated");
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/transfers/$transferId/delete/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 204) {
        print('Transfer deleted successfully');
      } else {
        print('Failed to delete transfer: ${response.body}');
      }
    } catch (error) {
      print('Error deleting transfer: $error');
    }
  }

  Future<Map<String, dynamic>?> fetchCategoryFromTransfer(
      int transferId) async {
    String? token = await _getToken();

    if (token == null) {
      print("User not authenticated");
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transfers/$transferId/category/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to fetch category: ${response.body}');
        return null;
      }
    } catch (error) {
      print('Error fetching category: $error');
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchAccountFromTransfer(int transferId) async {
    String? token = await _getToken();

    if (token == null) {
      print("User not authenticated");
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transfers/$transferId/account/'),
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
    } catch (error) {
      print('Error fetching account: $error');
      return null;
    }
  }

  Future<List<dynamic>?> fetchRegularTransfers() async {
    String? token = await _getToken();

    if (token == null) {
      print("User not authenticated");
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transfers/regular/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to fetch regular transfers: ${response.body}');
        return null;
      }
    } catch (error) {
      print('Error fetching regular transfers: $error');
      return null;
    }
  }
}
