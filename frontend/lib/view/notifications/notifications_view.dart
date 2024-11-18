import 'package:flutter/material.dart';
import 'package:frontend/view/notifications/notifications_manage_view.dart';
import 'package:intl/intl.dart';
import 'package:frontend/services/notifications_service.dart';
import 'package:frontend/view/notifications/notifications_create_view.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  _NotificationsViewState createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  List<Map<String, dynamic>> notifications = [];
  final NotificationsService _notificationsService = NotificationsService();
  int currentPage = 1;
  bool hasNextPage = true;

  String selectedPeriod = 'Day';
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  Future<void> loadNotifications({int page = 1}) async {
    final fetchedNotifications = await _notificationsService.fetchNotifications(
      period: selectedPeriod.toLowerCase(),
      date: selectedDate,
      page: page,
    );

    if (fetchedNotifications != null) {
      setState(() {
        notifications = (fetchedNotifications['results'] as List)
            .map((notification) => {
                  "notification_id": notification["id"],
                  "message": notification["message"],
                  "send_at": notification["send_at"],
                  "icon": _getIconFromString(notification["category_icon"]),
                  "color": _parseColor(notification["category_color"]),
                })
            .toList();
        currentPage = page;
        hasNextPage = page < fetchedNotifications['total_pages'];
      });
    } else {
      print("Failed to load notifications.");
    }
  }

  IconData _getIconFromString(String iconString) {
    int codePoint = int.tryParse(iconString) ?? 0;
    return IconData(codePoint, fontFamily: 'MaterialIcons');
  }

  Color _parseColor(String colorString) {
    return Color(
        int.parse(colorString.substring(1, 7), radix: 16) + 0xFF000000);
  }

  String getFormattedPeriod() {
    if (selectedPeriod == 'Day') {
      return DateFormat('EEEE, MMMM d, yyyy').format(selectedDate);
    } else if (selectedPeriod == 'Week') {
      DateTime firstDayOfWeek =
          selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
      DateTime lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 6));
      return "${DateFormat('MMM d').format(firstDayOfWeek)} - ${DateFormat('MMM d').format(lastDayOfWeek)}";
    } else if (selectedPeriod == 'Month') {
      return DateFormat('MMMM yyyy').format(selectedDate);
    } else {
      return DateFormat('yyyy').format(selectedDate);
    }
  }

  void goToPreviousPeriod() {
    setState(() {
      if (selectedPeriod == 'Day') {
        selectedDate = selectedDate.subtract(const Duration(days: 1));
      } else if (selectedPeriod == 'Week') {
        selectedDate = selectedDate.subtract(const Duration(days: 7));
      } else if (selectedPeriod == 'Month') {
        selectedDate = DateTime(
            selectedDate.year, selectedDate.month - 1, selectedDate.day);
      } else if (selectedPeriod == 'Year') {
        selectedDate = DateTime(
            selectedDate.year - 1, selectedDate.month, selectedDate.day);
      }
    });
    loadNotifications();
  }

  void goToNextPeriod() {
    setState(() {
      if (selectedPeriod == 'Day') {
        selectedDate = selectedDate.add(const Duration(days: 1));
      } else if (selectedPeriod == 'Week') {
        selectedDate = selectedDate.add(const Duration(days: 7));
      } else if (selectedPeriod == 'Month') {
        selectedDate = DateTime(
            selectedDate.year, selectedDate.month + 1, selectedDate.day);
      } else if (selectedPeriod == 'Year') {
        selectedDate = DateTime(
            selectedDate.year + 1, selectedDate.month, selectedDate.day);
      }
    });
    loadNotifications();
  }

  void createNotificationClick() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationsCreateView(),
      ),
    ).then((value) {
      if (value == true) {
        loadNotifications();
      }
    });
  }

  void goToNextPage() {
    if (hasNextPage) {
      loadNotifications(page: currentPage + 1);
    }
  }

  void goToPreviousPage() {
    if (currentPage > 1) {
      loadNotifications(page: currentPage - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF132D46),
      body: Column(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildPeriodSelector("Year"),
                    _buildPeriodSelector("Month"),
                    _buildPeriodSelector("Week"),
                    _buildPeriodSelector("Day"),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon:
                          const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: goToPreviousPeriod,
                    ),
                    Text(
                      getFormattedPeriod(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios,
                          color: Colors.white),
                      onPressed: goToNextPeriod,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: notifications.length + 1,
              itemBuilder: (context, index) {
                if (index == notifications.length) {
                  return _buildCreateNewNotificationButton();
                }
                final notification = notifications[index];
                return notificationItem(notification);
              },
            ),
          ),
          const SizedBox(height: 10),
          _buildPaginationControls(),
        ],
      ),
    );
  }

  Widget _buildPaginationControls() {
    int totalPages = hasNextPage ? currentPage + 1 : currentPage;

    int startPage = currentPage - 2 > 0 ? currentPage - 2 : 1;
    int endPage = startPage + 4;

    if (endPage > totalPages) {
      endPage = totalPages;
      startPage = endPage - 4 > 0 ? endPage - 4 : 1;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: currentPage > 1 ? goToPreviousPage : null,
        ),
        ...List.generate(
          (endPage - startPage + 1),
          (index) {
            int pageNumber = startPage + index;
            return GestureDetector(
              onTap: () {
                if (pageNumber != currentPage) {
                  loadNotifications(page: pageNumber);
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: pageNumber == currentPage
                      ? Colors.white
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2.0,
                  ),
                ),
                child: Text(
                  '$pageNumber',
                  style: TextStyle(
                    color:
                        pageNumber == currentPage ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
          onPressed: hasNextPage ? goToNextPage : null,
        ),
      ],
    );
  }

  Widget _buildPeriodSelector(String period) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedPeriod = period;
          });
          loadNotifications();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selectedPeriod == period
                    ? Colors.white
                    : Colors.transparent,
                width: 2.0,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            period,
            style: TextStyle(
              color: selectedPeriod == period ? Colors.white : Colors.grey,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget notificationItem(Map<String, dynamic> notification) {
    DateTime sendAt = notification['send_at'];
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotificationsManageView(
              notificationId: notification["notification_id"],
            ),
          ),
        );
        if (result == true) {
          loadNotifications();
        }
      },
      child: Container(
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
                color: notification['color'],
                shape: BoxShape.circle,
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
                    "${sendAt.day}/${sendAt.month}/${sendAt.year}",
                    style: const TextStyle(
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
}
