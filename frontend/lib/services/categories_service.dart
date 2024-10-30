import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CategoriesService {
  final String baseUrl = 'http://10.0.2.2:8000/api'; 

  Future<List<dynamic>?> fetchCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token == null) {
      print("User not authenticated");
      return null;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/categories/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', 
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to fetch categories: ${response.body}');
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchCategoryById(int categoryId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token == null) {
      print("User not authenticated");
      return null;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/categories/$categoryId/'),
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
  }

  Future<void> createCategory(String categoryName, String categoryType,
      String categoryColor, String categoryIcon) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token == null) {
      print("User not authenticated");
      return;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/categories/create/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'category_name': categoryName,
        'category_type': categoryType,
        'category_color': categoryColor,
        'category_icon': categoryIcon,
      }),
    );

    if (response.statusCode == 201) {
      print('Category created successfully');
    } else {
      print('Failed to create category: ${response.body}');
    }
  }

  Future<void> updateCategory(int categoryId, String categoryName,
      String categoryType, String categoryColor, String categoryIcon) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token == null) {
      print("User not authenticated");
      return;
    }

    final response = await http.put(
      Uri.parse('$baseUrl/categories/$categoryId/edit/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'category_name': categoryName,
        'category_type': categoryType,
        'category_color': categoryColor,
        'category_icon': categoryIcon,
      }),
    );

    if (response.statusCode == 200) {
      print('Category updated successfully');
    } else {
      print('Failed to update category: ${response.body}');
    }
  }

  Future<void> deleteCategory(int categoryId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token == null) {
      print("User not authenticated");
      return;
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/categories/$categoryId/delete/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 204) {
      print('Category soft-deleted successfully');
    } else {
      print('Failed to delete category: ${response.body}');
    }
  }
}
