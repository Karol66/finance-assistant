import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Do formatowania daty

class NotificationsCreateView extends StatefulWidget {
  const NotificationsCreateView({super.key});

  @override
  _NotificationsCreateViewState createState() => _NotificationsCreateViewState();
}

class _NotificationsCreateViewState extends State<NotificationsCreateView> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _createdAtController = TextEditingController();
  final TextEditingController _sendAtController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  // bool _isDeleted = false;
  Color? _selectedColor;
  IconData? _selectedIcon;

  final List<int> _userIds = [1, 2, 3]; // Przykładowe ID użytkowników
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

  // Wybór daty
  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  // Widget do wprowadzania danych tekstowych
  Widget inputTextField(String hintText, TextEditingController controller, {bool isNumeric = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
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

  // Widget do wyboru użytkownika
  Widget dropdownField(String hint, List<int> options, int? selectedValue, Function(int?) onChanged) {
    return DropdownButtonFormField<int>(
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      value: selectedValue,
      onChanged: onChanged,
      items: options.map((int value) {
        return DropdownMenuItem<int>(
          value: value,
          child: Text(value.toString()),
        );
      }).toList(),
    );
  }

  // Widget wyboru daty
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
      onTap: () => _selectDate(context, controller),
    );
  }

  // Widget do wyboru koloru
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

  // Widget do wyboru ikony
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              inputTextField('Message', _messageController),
              const SizedBox(height: 20),

              dropdownField('Select User', _userIds, null, (int? newValue) {
                setState(() {
                  _userIdController.text = newValue.toString();
                });
              }),
              const SizedBox(height: 20),

              datePickerField('Select Created At Date', _createdAtController),
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
                  onPressed: () {
                    print('Notification created with message: ${_messageController.text}');
                    print('Created At: ${_createdAtController.text}');
                    print('Send At: ${_sendAtController.text}');
                    print('User ID: ${_userIdController.text}');
                    print('Selected Color: $_selectedColor');
                    print('Selected Icon: $_selectedIcon');
                  },
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
    );
  }
}
