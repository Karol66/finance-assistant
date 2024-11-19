import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LinearRegressionService {
  final String baseUrl = 'http://10.0.2.2:8000/api';

  Future<List<Map<String, dynamic>>?> fetchPredictedExpenses() async {
    return await _fetchPredictedData('$baseUrl/predict-expenses/');
  }

  Future<List<Map<String, dynamic>>?> fetchPredictedIncome() async {
    return await _fetchPredictedData('$baseUrl/predict-income/');
  }

  Future<List<Map<String, dynamic>>?> fetchPredictedNetSavings() async {
    return await _fetchPredictedData('$baseUrl/predict-net-savings/');
  }

  Future<List<Map<String, dynamic>>?>
      fetchPredictedAndAllocatedSavings() async {
    return await _fetchPredictedData('$baseUrl/predict-and-allocate-savings/');
  }

  Future<List<Map<String, dynamic>>?> _fetchPredictedData(String url) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token == null) {
      throw Exception("User not authenticated. Please log in again.");
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
        final data = jsonDecode(response.body);

        if (data is List) {
          return List<Map<String, dynamic>>.from(
            data.map((item) => item as Map<String, dynamic>),
          );
        } else {
          throw Exception("Unexpected response format from $url.");
        }
      } else {
        final Map<String, dynamic>? errorData = jsonDecode(response.body);
        final errorMessage =
            errorData?['error'] ?? 'Failed to fetch data from server.';
        throw Exception('Error: $errorMessage');
      }
    } catch (e) {
      print('Error fetching data from $url: $e');
      throw Exception("Failed to fetch data: $e");
    }
  }
}
