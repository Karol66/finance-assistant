import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/services/notifications_service.dart';

class NotificationsCreateView extends StatefulWidget {
  const NotificationsCreateView({super.key});

  @override
  _NotificationsCreateViewState createState() => _NotificationsCreateViewState();
}

class _NotificationsCreateViewState extends State<NotificationsCreateView> {
  final _formKey = GlobalKey<FormState>();
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
    Icons.coffee,
  ];

  Future<void> _addNotification() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedColor == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a color.")),
        );
        return;
      }
      if (_selectedIcon == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select an icon.")),
        );
        return;
      }

      String message = _messageController.text;
      String sendAt = DateFormat('yyyy-MM-dd').format(_selectedSendAtDate!); 
      String notificationColor = '#${_selectedColor?.value.toRadixString(16).substring(2, 8)}';
      String notificationIcon = _selectedIcon != null
          ? _selectedIcon!.codePoint.toString()
          : 'default_icon';

      await _notificationsService.createNotification(
        message,
        sendAt,
        notificationColor,
        notificationIcon,
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields correctly.")),
      );
    }
  }

  Future<void> _selectSendAtDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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

  Widget inputTextField(String hintText, TextEditingController controller) {
    return TextFormField(
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
    );
  }

  Widget datePickerField(String hintText, TextEditingController controller) {
    return TextFormField(
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
      validator: (value) {
        if (_selectedSendAtDate == null) {
          return 'Please select a date';
        }
        return null;
      },
    );
  }

  Widget colorPicker() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _colorOptions.map((color) {
          return GestureDetector(
            onTap: () => setState(() {
              _selectedColor = color;
            }),
            child: Container(
              width: 30,
              height: 30,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(15),
                border: _selectedColor == color
                    ? Border.all(color: Colors.white, width: 3)
                    : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
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
              color: _selectedIcon == iconData
                  ? (_selectedColor ?? const Color(0xFF191E29))
                  : const Color(0xFF191E29),
              borderRadius: BorderRadius.circular(15),
              border: _selectedIcon == iconData
                  ? Border.all(color: Colors.white, width: 3)
                  : null,
            ),
            child: Icon(
              iconData,
              size: 40,
              color: Colors.white,
            ),
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
        title: const Text('Create Notification'),
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
          child: Form(
            key: _formKey,
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
                    onPressed: _addNotification,
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size.fromHeight(58),
                      backgroundColor: const Color(0xFF01C38D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Add Notification',
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
      ),
    );
  }
}
