import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GoalsService {
  final String baseUrl = 'http://10.0.2.2:8000/api';

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwtToken');
  }

  Future<Map<String, dynamic>?> fetchGoals({int page = 1, String? status}) async {
    String? token = await _getToken();

    if (token == null) {
      print("User not authenticated");
      return null;
    }

    // Dodaj filtr statusu do URL-a, jeśli podano
    String url = '$baseUrl/goals/?page=$page';
    if (status != null) {
      url += '&status=$status';
    }

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
            .map((goal) => {
                  "id": goal["id"],
                  "goal_name": goal["goal_name"],
                  "target_amount": goal["target_amount"],
                  "current_amount": goal["current_amount"],
                  "priority": goal["priority"],
                  "goal_color": goal["goal_color"],
                  "goal_icon": goal["goal_icon"],
                  "status": goal["status"], 
                })
            .toList(),
        'total_pages': totalPages,
      };
    } else {
      print('Failed to fetch goals: ${response.body}');
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchGoalById(int goalId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token == null) {
      print("User not authenticated");
      return null;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/goals/$goalId/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to fetch goal: ${response.body}');
      return null;
    }
  }

  Future<void> createGoal(
      String goalName,
      String targetAmount,
      String currentAmount,
      int priority,
      String goalColor,
      String goalIcon) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token == null) {
      print("User not authenticated");
      return;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/goals/create/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'goal_name': goalName,
        'target_amount': targetAmount,
        'current_amount': currentAmount,
        'priority': priority,
        'goal_color': goalColor,
        'goal_icon': goalIcon,
      }),
    );

    if (response.statusCode == 201) {
      print('Goal created successfully');
    } else {
      print('Failed to create goal: ${response.body}');
    }
  }

  Future<void> updateGoal(
      int goalId,
      String goalName,
      String targetAmount,
      String currentAmount,
      int priority,
      String goalColor,
      String goalIcon) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token == null) {
      print("User not authenticated");
      return;
    }

    final response = await http.put(
      Uri.parse('$baseUrl/goals/$goalId/edit/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'goal_name': goalName,
        'target_amount': targetAmount,
        'current_amount': currentAmount,
        'priority': priority,
        'goal_color': goalColor,
        'goal_icon': goalIcon,
      }),
    );

    if (response.statusCode == 200) {
      print('Goal updated successfully');
    } else {
      print('Failed to update goal: ${response.body}');
    }
  }

  Future<void> deleteGoal(int goalId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token == null) {
      print("User not authenticated");
      return;
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/goals/$goalId/delete/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 204) {
      print('Goal soft-deleted successfully');
    } else {
      print('Failed to delete goal: ${response.body}');
    }
  }
}
