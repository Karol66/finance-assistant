import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/services/notifications_service.dart';

class NotificationsManageView extends StatefulWidget {
  final int notificationId;

  const NotificationsManageView({super.key, required this.notificationId});

  @override
  _NotificationsManageViewState createState() => _NotificationsManageViewState();
}

class _NotificationsManageViewState extends State<NotificationsManageView> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _sendAtController = TextEditingController();
  final NotificationsService _notificationsService = NotificationsService();

  Color? _selectedColor;
  IconData? _selectedIcon;
  DateTime? _selectedSendAtDate;

  final List<Color> _colorOptions = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.brown,
    Colors.pink,
    Colors.grey,
  ];

  final List<IconData> _iconOptions = [
    Icons.directions_car,
    Icons.phone,
    Icons.bolt,
    Icons.flight,
    Icons.network_wifi,
    Icons.home,
    Icons.food_bank,
    Icons.school,
    Icons.health_and_safety,
    Icons.theater_comedy,
    Icons.shopping_bag,
    Icons.sports,
    Icons.work,
    Icons.forest,
    Icons.travel_explore,
  ];

  @override
  void initState() {
    super.initState();
    _loadNotification();
  }

  Future<void> _loadNotification() async {
    final fetchedNotification = await _notificationsService.fetchNotificationById(widget.notificationId);
    if (fetchedNotification != null) {
      setState(() {
        _messageController.text = fetchedNotification['message'];
        _selectedSendAtDate = DateTime.parse(fetchedNotification['send_at']);
        _sendAtController.text = DateFormat('yyyy-MM-dd').format(_selectedSendAtDate!);
        _selectedColor = _parseColor(fetchedNotification['category_color']);
        _selectedIcon = _getIconFromString(fetchedNotification['category_icon']);
      });
    }
  }

  Future<void> _updateNotification() async {
    if (_messageController.text.isEmpty || _selectedSendAtDate == null || _selectedColor == null || _selectedIcon == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill in all fields.")));
      return;
    }

    String message = _messageController.text;
    String sendAt = DateFormat('yyyy-MM-dd').format(_selectedSendAtDate!);
    String categoryColor = '#${_selectedColor?.value.toRadixString(16).substring(2, 8)}';
    String categoryIcon = _selectedIcon!.codePoint.toString();

    await _notificationsService.updateNotification(
      widget.notificationId,
      message,
      sendAt,
      categoryColor,
      categoryIcon,
      false, // is_deleted set to false for update
    );

    Navigator.pop(context, true);
  }

  Future<void> _deleteNotification() async {
    await _notificationsService.deleteNotification(widget.notificationId);
    Navigator.pop(context, true);
  }

  Future<void> _selectSendAtDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedSendAtDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedSendAtDate = picked;
        _sendAtController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  IconData _getIconFromString(String iconString) {
    int codePoint = int.tryParse(iconString) ?? 0;
    return IconData(codePoint, fontFamily: 'MaterialIcons');
  }

  Color _parseColor(String colorString) {
    return Color(int.parse(colorString.substring(1, 7), radix: 16) + 0xFF000000);
  }

  Widget inputTextField(String hintText, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget datePickerField(String hintText, TextEditingController controller) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        suffixIcon: const Icon(
          Icons.calendar_today,
          color: Color(0xFF494E59),
        ),
      ),
      onTap: () => _selectSendAtDate(context),
    );
  }

  Widget colorPicker() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _colorOptions.map((color) {
          return GestureDetector(
            onTap: () => _onColorSelected(color),
            child: Container(
              width: 30,
              height: 30,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: (_selectedColor?.value == color.value)
                      ? Colors.white
                      : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _onColorSelected(Color color) {
    setState(() {
      _selectedColor = color;
    });
  }

  Widget iconPicker() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 4,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      physics: const NeverScrollableScrollPhysics(),
      children: _iconOptions.map((iconData) {
        return GestureDetector(
          onTap: () => setState(() {
            _selectedIcon = iconData;
          }),
          child: Container(
            decoration: BoxDecoration(
              color: _selectedIcon == iconData ? (_selectedColor ?? const Color(0xFF191E29)) : const Color(0xFF191E29),
              borderRadius: BorderRadius.circular(15),
              border: _selectedIcon == iconData ? Border.all(color: Colors.white, width: 3) : null,
            ),
            child: Icon(iconData, size: 40, color: Colors.white),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF132D46),
      appBar: AppBar(
        title: const Text('Manage Notification'),
        backgroundColor: const Color(0xFF0B6B3A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              inputTextField('Message', _messageController),
              const SizedBox(height: 20),
              datePickerField('Select Send At Date', _sendAtController),
              const SizedBox(height: 20),
              const Text(
                'Select Color:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              colorPicker(),
              const SizedBox(height: 20),
              const Text(
                'Select Icon:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              iconPicker(),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updateNotification,
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size.fromHeight(58),
                    backgroundColor: const Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Update Notification',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _deleteNotification,
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size.fromHeight(58),
                    backgroundColor: const Color(0xFFF44336),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Delete Notification',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
