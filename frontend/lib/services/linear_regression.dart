import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LinearRegressionService {
  final String baseUrl = 'http://10.0.2.2:8000/api';

  // Fetch predicted expenses
  Future<List<Map<String, dynamic>>?> fetchPredictedExpenses() async {
    return await _fetchPredictedData('$baseUrl/predict-expenses/');
  }

  // Fetch predicted income
  Future<List<Map<String, dynamic>>?> fetchPredictedIncome() async {
    return await _fetchPredictedData('$baseUrl/predict-income/');
  }

  // Fetch predicted net savings (income - expenses)
  Future<List<Map<String, dynamic>>?> fetchPredictedNetSavings() async {
    return await _fetchPredictedData('$baseUrl/predict-net-savings/');
  }

  // Fetch predicted and allocated savings for goals
  Future<List<Map<String, dynamic>>?> fetchPredictedAndAllocatedSavings() async {
    return await _fetchPredictedData('$baseUrl/predict-and-allocate-savings/');
  }

  // Helper function to fetch data from the given endpoint
  Future<List<Map<String, dynamic>>?> _fetchPredictedData(String url) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    // Check if the user is authenticated by checking the JWT token
    if (token == null) {
      print("User not authenticated");
      return null;
    }

    try {
      // Make the API request
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Check the response status code
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Ensure the response structure matches the expected format (a list of maps)
        if (data is List) {
          return List<Map<String, dynamic>>.from(data.map((item) => item as Map<String, dynamic>));
        } else {
          print("Unexpected response format from $url. Response data: $data");
          return null;
        }
      } else {
        print('Failed to fetch data from $url: ${response.body}');
        return null;
      }
    } catch (e) {
      // Catch any exceptions and log the error
      print('Error fetching data from $url: $e');
      return null;
    }
  }
}
