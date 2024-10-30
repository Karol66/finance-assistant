import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LinearRegressionService {
  final String baseUrl = 'http://10.0.2.2:8000/api';

  Future<List<double>?> fetchPredictedSavings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token == null) {
      print("User not authenticated");
      return null;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/predict-savings/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<double>.from(data['predicted_savings']);
    } else {
      print('Failed to fetch predicted savings: ${response.body}');
      return null;
    }
  }

  Future<List<dynamic>?> fetchSavingStrategy() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token == null) {
      print("User not authenticated");
      return null;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/propose-saving-strategy/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['strategy'];
    } else {
      print('Failed to fetch saving strategy: ${response.body}');
      return null;
    }
  }
}