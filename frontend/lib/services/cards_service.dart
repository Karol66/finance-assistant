import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CardsService {
  final String baseUrl = 'http://10.0.2.2:8000/api';

  Future<List<dynamic>?> fetchCards() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token == null) {
      print("User not authenticated");
      return null;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/cards/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to fetch cards: ${response.body}');
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchCardById(int cardId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token == null) {
      print("User not authenticated");
      return null;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/cards/$cardId/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to fetch card: ${response.body}');
      return null;
    }
  }

  Future<void> createCard(String cardName, String cardNumber, String cvv,
      String bankName, String valid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token == null) {
      print("User not authenticated");
      return;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/cards/create/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'card_name': cardName,
        'card_number': cardNumber,
        'cvv': cvv,
        'bank_name': bankName,
        'valid': valid,
      }),
    );

    if (response.statusCode == 201) {
      print('Card created successfully');
    } else {
      print('Failed to create card: ${response.body}');
    }
  }

  Future<void> updateCard(int cardId, String cardName, String cardNumber,
      String cvv, String bankName, String valid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token == null) {
      print("User not authenticated");
      return;
    }

    final response = await http.put(
      Uri.parse('$baseUrl/cards/$cardId/edit/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'card_name': cardName,
        'card_number': cardNumber,
        'cvv': cvv,
        'bank_name': bankName,
        'valid': valid,
      }),
    );

    if (response.statusCode == 200) {
      print('Card updated successfully');
    } else {
      print('Failed to update card: ${response.body}');
    }
  }

  Future<void> deleteCard(int cardId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token == null) {
      print("User not authenticated");
      return;
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/cards/$cardId/delete/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 204) {
      print('Card soft-deleted successfully');
    } else {
      print('Failed to delete card: ${response.body}');
    }
  }
}
