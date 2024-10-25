import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsService {
  final String baseUrl = 'http://10.0.2.2:8000/api';

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwtToken');
  }

  Future<List<Map<String, dynamic>>?> fetchNotifications() async {
    String? token = await _getToken();

    if (token == null) {
      print("User not authenticated");
      return null;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/notifications/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((notification) => {
            "id": notification["id"],
            "message": notification["message"],
            "created_at": DateTime.parse(notification["created_at"]),
            "send_at": DateTime.parse(notification["send_at"]),
            "category_color": notification["category_color"],
            "category_icon": notification["category_icon"],
            "is_deleted": notification["is_deleted"]
          }).toList();
    } else {
      print('Failed to fetch notifications: ${response.body}');
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchNotificationById(int notificationId) async {
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

  Future<void> createNotification(
      String message,
      String sendAt,
      String categoryColor,
      String categoryIcon) async {
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
}
