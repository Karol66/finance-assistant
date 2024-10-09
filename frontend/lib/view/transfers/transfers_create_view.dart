import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransfersCreateView extends StatefulWidget {
  const TransfersCreateView({super.key});

  @override
  _TransfersCreateViewState createState() => _TransfersCreateViewState();
}

class _TransfersCreateViewState extends State<TransfersCreateView> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController =
      TextEditingController(); 

  DateTime? _selectedDate; 

  int? _selectedAccountId;
  IconData? _selectedCategoryIcon; 

  final List<int> _accountOptions = [1, 2, 3]; 

  final List<IconData> _categoryIconOptions = [
    Icons.home,
    Icons.shopping_bag,
    Icons.food_bank,
    Icons.school,
    Icons.health_and_safety,
    Icons.theater_comedy,
    Icons.car_crash,
    Icons.sports,
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text =
            DateFormat('yyyy-MM-dd').format(picked); 
      });
    }
  }

  Widget inputTextField(String hintText, TextEditingController controller,
      {bool isNumeric = false}) {
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
        suffixIcon: Icon(
          Icons.calendar_today,
          color: Color(0xFF494E59), 
        ),
      ),
      onTap: () => _selectDate(context), 
    );
  }

  Widget dropdownField(String hint, List<int> options, int? selectedValue,
      Function(int?) onChanged) {
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

  final List<String> _categoryNames = [
    'Home',
    'Shopping',
    'Food',
    'School',
    'Health',
    'Play',
    'Car',
    'Sports',
  ];

  Widget categoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, 
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _categoryIconOptions.length, 
      itemBuilder: (context, index) {
        final iconData = _categoryIconOptions[index];
        final categoryName =
            _categoryNames[index];

        return GestureDetector(
          onTap: () => setState(() {
            _selectedCategoryIcon = iconData;
          }),
          child: Container(
            decoration: BoxDecoration(
              color: _selectedCategoryIcon == iconData
                  ? const Color(0xFF01C38D)
                  : const Color(0xFF191E29),
              borderRadius: BorderRadius.circular(15),
              border: _selectedCategoryIcon == iconData
                  ? Border.all(color: Colors.white, width: 3)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  iconData,
                  size: 40,
                  color: Colors.white,
                ),
                const SizedBox(height: 5),
                Text(
                  categoryName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF132D46),
      appBar: AppBar(
        title: const Text('Create Transfer'),
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
              inputTextField('Amount', _amountController, isNumeric: true),
              const SizedBox(height: 20),

              datePickerField('Select Date', _dateController),
              const SizedBox(height: 20),

              inputTextField('Description', _descriptionController),
              const SizedBox(height: 20),

              dropdownField(
                  'Select Account', _accountOptions, _selectedAccountId,
                  (int? newValue) {
                setState(() {
                  _selectedAccountId = newValue;
                });
              }),
              const SizedBox(height: 20),

              const Text(
                'Select Category:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              categoryGrid(),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    print(
                        'Transfer created with amount: ${_amountController.text}');
                    print('Description: ${_descriptionController.text}');
                    print('Selected Date: ${_selectedDate.toString()}');
                    print('Selected Account ID: $_selectedAccountId');
                    print('Selected Category Icon: $_selectedCategoryIcon');
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size.fromHeight(58), 
                    backgroundColor:
                        const Color(0xFF01C38D), 
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8), 
                    ),
                  ),
                  child: const Text(
                    'Add Transfer',
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
