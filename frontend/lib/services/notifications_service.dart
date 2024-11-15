import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsService {
  final String baseUrl = 'http://10.0.2.2:8000/api';

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwtToken');
  }

  Future<List<Map<String, dynamic>>?> fetchNotifications({
    String period = 'day',
    DateTime? date,
    int page = 1, // Add page parameter with a default value of 1
  }) async {
    String? token = await _getToken();

    if (token == null) {
      print("User not authenticated");
      return null;
    }

    final dateString = date != null ? DateFormat('yyyy-MM-dd').format(date) : '';
    final response = await http.get(
      Uri.parse(
          '$baseUrl/notifications/?period=$period&date=$dateString&page=$page'), // Include page parameter in URL
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);

      // Extract results from the paginated response
      List<dynamic> results = data['results'];

      return results
          .map((notification) => {
                "id": notification["id"],
                "message": notification["message"],
                "created_at": DateTime.parse(notification["created_at"]),
                "send_at": DateTime.parse(notification["send_at"]),
                "category_color": notification["category_color"],
                "category_icon": notification["category_icon"],
                "is_deleted": notification["is_deleted"]
              })
          .toList();
    } else {
      print('Failed to fetch notifications: ${response.body}');
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchNotificationById(
      int notificationId) async {
    String? token = await _getToken();

    if (token == null) {
      print("User not authenticated");
      return null;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/notifications/$notificationId/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to fetch notification: ${response.body}');
      return null;
    }
  }

  Future<void> createNotification(String message, String sendAt,
      String categoryColor, String categoryIcon) async {
    String? token = await _getToken();

    if (token == null) {
      print("User not authenticated");
      return;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/notifications/create/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'message': message,
        'send_at': sendAt,
        'category_color': categoryColor,
        'category_icon': categoryIcon,
        'is_deleted': false,
      }),
    );

    if (response.statusCode == 201) {
      print('Notification created successfully');
    } else {
      print('Failed to create notification: ${response.body}');
    }
  }

  Future<void> updateNotification(
      int notificationId,
      String message,
      String sendAt,
      String categoryColor,
      String categoryIcon,
      bool isDeleted) async {
    String? token = await _getToken();

    if (token == null) {
      print("User not authenticated");
      return;
    }

    final response = await http.put(
      Uri.parse('$baseUrl/notifications/$notificationId/edit/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'message': message,
        'send_at': sendAt,
        'category_color': categoryColor,
        'category_icon': categoryIcon,
        'is_deleted': isDeleted,
      }),
    );

    if (response.statusCode == 200) {
      print('Notification updated successfully');
    } else {
      print('Failed to update notification: ${response.body}');
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    String? token = await _getToken();

    if (token == null) {
      print("User not authenticated");
      return;
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/notifications/$notificationId/delete/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 204) {
      print('Notification deleted successfully');
    } else {
      print('Failed to delete notification: ${response.body}');
    }
  }

  Future<int> fetchTodayNotificationsCount() async {
    String? token = await _getToken();

    if (token == null) {
      print("User not authenticated");
      return 0;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/notifications/today_count/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['count'] ?? 0;
    } else {
      print('Failed to fetch today\'s notification count: ${response.body}');
      return 0;
    }
  }
}
