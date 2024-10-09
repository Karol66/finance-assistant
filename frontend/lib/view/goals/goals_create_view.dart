import 'package:flutter/material.dart';

class GoalsCreateView extends StatefulWidget {
  const GoalsCreateView({super.key});

  @override
  _GoalsCreateViewState createState() => _GoalsCreateViewState();
}

class _GoalsCreateViewState extends State<GoalsCreateView> {
  final TextEditingController _goalNameController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _amountSpentController = TextEditingController();
  final TextEditingController _remainingController = TextEditingController();

  IconData? _selectedCategoryIcon;
  Color? _selectedProgressColor;

  final List<IconData> _categoryIconOptions = [
    Icons.directions_car,
    Icons.home,
    Icons.shopping_bag,
    Icons.school,
    Icons.health_and_safety,
    Icons.food_bank,
    Icons.theater_comedy,
    Icons.sports,
  ];

  final List<String> _categoryNames = [
    'Auto',
    'Home',
    'Shopping',
    'School',
    'Health',
    'Food',
    'Play',
    'Sports',
  ];

  final List<Color> _progressColors = [
    Colors.green,
    Colors.red,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
    Colors.brown,
    Colors.pink,
    Colors.grey,
  ];

  void _onColorSelected(Color color) {
    setState(() {
      _selectedProgressColor = color;
    });
  }

  void _onIconSelected(IconData icon) {
    setState(() {
      _selectedCategoryIcon = icon;
    });
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
        final categoryName = _categoryNames[index];

        return GestureDetector(
          onTap: () => _onIconSelected(iconData),
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

  Widget progressColorPicker() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _progressColors.map((color) {
          return GestureDetector(
            onTap: () => _onColorSelected(color),
            child: Container(
              width: 30,
              height: 30,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(15),
                border: _selectedProgressColor == color
                    ? Border.all(color: Colors.white, width: 3)
                    : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF132D46),
      appBar: AppBar(
        title: const Text('Create Goal'),
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
              inputTextField('Goal Name', _goalNameController),
              const SizedBox(height: 20),
              inputTextField('Budget', _budgetController, isNumeric: true),
              const SizedBox(height: 20),
              inputTextField('Amount Spent', _amountSpentController,
                  isNumeric: true),
              const SizedBox(height: 20),
              inputTextField('Remaining', _remainingController,
                  isNumeric: true),
              const SizedBox(height: 20),

              const Text(
                'Select Goal Color:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              progressColorPicker(),
              const SizedBox(height: 20),

              const Text(
                'Select Goal Icon:',
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
                    print('Goal created with name: ${_goalNameController.text}');
                    print('Budget: ${_budgetController.text}');
                    print('Amount Spent: ${_amountSpentController.text}');
                    print('Remaining: ${_remainingController.text}');
                    print('Selected Category Icon: $_selectedCategoryIcon');
                    print('Selected Progress Color: $_selectedProgressColor');
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size.fromHeight(58),
                    backgroundColor: const Color(0xFF01C38D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Add Goal',
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
