import 'package:flutter/material.dart';
import 'package:frontend/view/notifications/notifications_create_view.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  _NotificationsViewState createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  List<Map<String, dynamic>> notifications = [
    {
      "id": 1,
      "message": "Pay the electricity bill",
      "send_at": DateTime(2023, 10, 5, 10, 0),
      "icon": Icons.notifications_active,
      "color": Colors.orange,
    },
    {
      "id": 2,
      "message": "Doctor's appointment",
      "send_at": DateTime(2023, 10, 3, 9, 0),
      "icon": Icons.medical_services,
      "color": Colors.red,
    },
    {
      "id": 3,
      "message": "Subscription renewal for Spotify",
      "send_at": DateTime(2023, 10, 7, 12, 0),
      "icon": Icons.music_note,
      "color": Colors.green,
    },
    {
      "id": 4,
      "message": "Car insurance payment",
      "send_at": DateTime(2023, 10, 10, 8, 0),
      "icon": Icons.directions_car,
      "color": Colors.blue,
    },
  ];

  void createNotificationClick() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationsCreateView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF132D46),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Container(
              width: media.width,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF191E29),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: _buildCalendarView(),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: notifications.length + 1, 
                itemBuilder: (context, index) {
                  if (index == notifications.length) {
                    return _buildCreateNewNotificationButton();
                  }
                  final notification = notifications[index];
                  return _buildNotificationItem(
                    icon: notification['icon'],
                    message: notification['message'],
                    sendAt: notification['send_at'],
                    color: notification['color'],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarView() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, 
      child: Row(
        children: List.generate(7, (index) {
          DateTime today = DateTime.now();
          DateTime date = today.add(Duration(days: index));

          return Column(
            children: [
              Text(
                _getWeekday(date),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white54,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 38, 
                height: 38, 
                margin: const EdgeInsets.symmetric(horizontal: 4), 
                alignment: Alignment.center, 
                decoration: BoxDecoration(
                  color: date.day == today.day
                      ? Colors.orange
                      : Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "${date.day}",
                  style: const TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  String _getWeekday(DateTime date) {
    const weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return weekdays[date.weekday - 1];
  }

  Widget _buildCreateNewNotificationButton() {
    return GestureDetector(
      onTap: createNotificationClick,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF01C38D),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add, size: 32, color: Colors.white),
            SizedBox(width: 10),
            Text(
              "Create New Notification",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required String message,
    required DateTime sendAt,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF191E29),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${sendAt.day}/${sendAt.month}/${sendAt.year} ${sendAt.hour}:${sendAt.minute.toString().padLeft(2, '0')}",
                  style: const TextStyle(
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
