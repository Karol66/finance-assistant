import 'package:flutter/material.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  _NotificationsViewState createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  // Przykładowe dane dla przypomnień/powiadomień
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

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF132D46),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Górna część z dniami tygodnia
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
            _buildNotificationsList(), // Lista powiadomień/przypomnień
          ],
        ),
      ),
    );
  }

  // Widok kalendarza (prosty kalendarz z datami dni tygodnia)
  Widget _buildCalendarView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (index) {
          DateTime today = DateTime.now();
          DateTime date = today.add(Duration(days: index));

          return Column(
            children: [
              Text(
                _getWeekday(date),
                style: const TextStyle(
                  fontSize: 16, // Minimalnie zwiększona wielkość nazw dni tygodnia
                  fontWeight: FontWeight.bold,
                  color: Colors.white54,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: date.day == today.day
                      ? Colors.orange
                      : Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "${date.day}",
                  style: const TextStyle(
                    fontSize: 18,
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

  // Pomocnicza funkcja do konwersji daty na nazwę dnia tygodnia
  String _getWeekday(DateTime date) {
    const weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return weekdays[date.weekday - 1];
  }

  // Widok listy powiadomień
  Widget _buildNotificationsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationItem(notification);
        },
      ),
    );
  }

  // Widok pojedynczego powiadomienia
  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF191E29), // Kolor tła dla powiadomienia
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 40, // Rozmiar ikony powiadomienia
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: notification['color'], // Kolor ikony
            ),
            child: Icon(notification['icon'], color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification['message'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${notification['send_at'].day}/${notification['send_at'].month}/${notification['send_at'].year} ${notification['send_at'].hour}:${notification['send_at'].minute.toString().padLeft(2, '0')}",
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
