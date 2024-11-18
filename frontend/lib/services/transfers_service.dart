import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TransfersService {
  final String baseUrl = 'http://10.0.2.2:8000/api';

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwtToken');
  }

  Future<Map<String, dynamic>?> fetchTransfers({
    int page = 1,
    String? type,
    String? period,
    DateTime? date,
  }) async {
    String? token = await _getToken();

    if (token == null) {
      print("User not authenticated");
      return null;
    }

    final dateString =
        date != null ? DateFormat('yyyy-MM-dd').format(date) : '';

    String url = '$baseUrl/transfers/?page=$page';
    if (type != null) {
      url += '&type=$type';
    }
    if (period != null) {
      url += '&period=$period';
    }
    if (dateString.isNotEmpty) {
      url += '&date=$dateString';
    }

    try {
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
              .map((transfer) => {
                    "id": transfer["id"],
                    "transfer_name": transfer["transfer_name"],
                    "amount": transfer["amount"],
                    "description": transfer["description"],
                    "date": transfer["date"],
                    "category": transfer["category"],
                    "category_color": transfer['category_color'],
                    "category_icon": transfer['category_icon'],
                    "category_type": transfer['category_type'],
                    "account": transfer["account"],
                    "is_regular": transfer["is_regular"],
                  })
              .toList(),
          'total_pages': totalPages,
        };
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

  Future<List<Map<String, dynamic>>?> fetchTransfersGroupedByCategory({
    String? type,
    String? period,
    DateTime? date,
  }) async {
    String? token = await _getToken();

    if (token == null) {
      print("User not authenticated");
      return null;
    }

    final dateString =
        date != null ? DateFormat('yyyy-MM-dd').format(date) : '';

    String url = '$baseUrl/transfers/grouped/';
    if (type != null) {
      url += '?type=$type';
    }
    if (period != null) {
      url += type != null ? '&period=$period' : '?period=$period';
    }
    if (dateString.isNotEmpty) {
      url += (type != null || period != null)
          ? '&date=$dateString'
          : '?date=$dateString';
    }

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) {
          return {
            'category': item['category'],
            'total_amount': item['total_amount'],
          };
        }).toList();
      } else {
        print('Failed to fetch grouped transfers: ${response.body}');
        return null;
      }
    } catch (error) {
      print('Error fetching grouped transfers: $error');
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchProfitLoss({
    String? type,
    String? period,
    DateTime? date,
  }) async {
    String? token = await _getToken();

    if (token == null) {
      print("User not authenticated");
      return null;
    }

    final dateString =
        date != null ? DateFormat('yyyy-MM-dd').format(date) : '';

    String url = '$baseUrl/transfers/calculate-profit-loss/';
    if (type != null) {
      url += '?type=$type';
    }
    if (period != null) {
      url += type != null ? '&period=$period' : '?period=$period';
    }
    if (dateString.isNotEmpty) {
      url += (type != null || period != null)
          ? '&date=$dateString'
          : '?date=$dateString';
    }

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        return {
          'total_income': data['total_income'] ?? 0,
          'total_expense': data['total_expense'] ?? 0,
          'profit_loss': data['profit_loss'] ?? 0,
        };
      } else {
        print('Failed to fetch profit/loss: ${response.body}');
        return null;
      }
    } catch (error) {
      print('Error fetching profit/loss: $error');
      return null;
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

  Future<Map<String, dynamic>?> fetchRegularTransfers({
    int page = 1,
    String? type,
    String? period,
    DateTime? date,
  }) async {
    String? token = await _getToken();

    if (token == null) {
      print("User not authenticated");
      return null;
    }

    final dateString =
        date != null ? DateFormat('yyyy-MM-dd').format(date) : '';

    String url = '$baseUrl/transfers/regular/?page=$page';
    if (type != null) {
      url += '&type=$type';
    }
    if (period != null) {
      url += '&period=$period';
    }
    if (dateString.isNotEmpty) {
      url += '&date=$dateString';
    }

    try {
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
              .map((transfer) => {
                    "id": transfer["id"],
                    "transfer_name": transfer["transfer_name"],
                    "amount": transfer["amount"],
                    "description": transfer["description"],
                    "date": transfer["date"],
                    "category": transfer["category"],
                    "category_color": transfer['category_color'],
                    "category_icon": transfer['category_icon'],
                    "category_type": transfer['category_type'],
                    "account": transfer["account"],
                    "is_regular": transfer["is_regular"],
                  })
              .toList(),
          'total_pages': totalPages,
        };
      } else {
        print('Failed to fetch regular transfers: ${response.body}');
        return null;
      }
    } catch (error) {
      print('Error fetching regular transfers: $error');
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchRegularTransferById(int transferId) async {
    String? token = await _getToken();

    if (token == null) {
      print("User not authenticated");
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transfers/regular/$transferId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to fetch regular transfer: ${response.body}');
        return null;
      }
    } catch (error) {
      print('Error fetching regular transfer: $error');
      return null;
    }
  }

  Future<void> createRegularTransfer(
      String transferName,
      String amount,
      String description,
      int accountId,
      int categoryId,
      String interval) async {
    String? token = await _getToken();

    if (token == null) {
      print("User not authenticated");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/transfers/regular/create/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'transfer_name': transferName,
          'amount': amount,
          'description': description,
          'account': accountId,
          'category': categoryId,
          'is_regular': true,
          'interval': interval,
        }),
      );

      if (response.statusCode == 201) {
        print('Regular transfer created successfully');
      } else {
        print('Failed to create regular transfer: ${response.body}');
      }
    } catch (error) {
      print('Error creating regular transfer: $error');
    }
  }

  Future<void> updateRegularTransfer(
      int transferId,
      String transferName,
      String amount,
      String description,
      int accountId,
      int categoryId,
      String interval) async {
    String? token = await _getToken();

    if (token == null) {
      print("User not authenticated");
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/transfers/regular/$transferId/edit/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'transfer_name': transferName,
          'amount': amount,
          'description': description,
          'account': accountId,
          'category': categoryId,
          'is_regular': true,
          'interval': interval,
        }),
      );

      if (response.statusCode == 200) {
        print('Regular transfer updated successfully');
      } else {
        print('Failed to update regular transfer: ${response.body}');
      }
    } catch (error) {
      print('Error updating regular transfer: $error');
    }
  }

  Future<void> deleteRegularTransfer(int transferId) async {
    String? token = await _getToken();

    if (token == null) {
      print("User not authenticated");
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/transfers/regular/$transferId/delete/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 204) {
        print('Regular transfer deleted successfully');
      } else {
        print('Failed to delete regular transfer: ${response.body}');
      }
    } catch (error) {
      print('Error deleting regular transfer: $error');
    }
  }

  Future<void> generateRegularTransfers() async {
    String? token = await _getToken();

    if (token == null) {
      print("User not authenticated");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/transfers/regular/generate/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 201) {
        print('Regular transfers generated successfully');
      } else {
        print('Failed to generate regular transfers: ${response.body}');
      }
    } catch (error) {
      print('Error generating regular transfers: $error');
    }
  }
}
