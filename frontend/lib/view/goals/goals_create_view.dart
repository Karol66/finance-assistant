import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/services/goals_service.dart';

class GoalsCreateView extends StatefulWidget {
  const GoalsCreateView({super.key});

  @override
  _GoalsCreateViewState createState() => _GoalsCreateViewState();
}

class _GoalsCreateViewState extends State<GoalsCreateView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _goalNameController = TextEditingController();
  final TextEditingController _targetAmountController = TextEditingController();
  final TextEditingController _currentAmountController =
      TextEditingController();
  final TextEditingController _priorityController = TextEditingController();
  final GoalsService _goalsService = GoalsService();

  IconData? _selectedGoalIcon;
  Color? _selectedGoalColor;

  final List<Color> _goalColorOptions = [
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

  final List<IconData> _goalIconOptions = [
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

  @override
  void initState() {
    super.initState();
  }

  Future<void> _addGoal() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedGoalColor == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a color.")),
        );
        return;
      }
      if (_selectedGoalIcon == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select an icon.")),
        );
        return;
      }

      await _goalsService.createGoal(
        _goalNameController.text,
        _targetAmountController.text,
        _currentAmountController.text,
        int.parse(_priorityController.text),
        '#${_selectedGoalColor?.value.toRadixString(16).substring(2, 8)}',
        _selectedGoalIcon!.codePoint.toString(),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields correctly.")),
      );
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

  void _onColorSelected(Color color) {
    setState(() {
      _selectedGoalColor = color;
    });
  }

  void _onIconSelected(IconData icon) {
    setState(() {
      _selectedGoalIcon = icon;
    });
  }

  Widget inputTextField(String hintText, TextEditingController controller,
      {bool isNumeric = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      inputFormatters: isNumeric
          ? [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ]
          : [],
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
        if (isNumeric) {
          String normalizedValue = value.replaceAll(',', '.');
          if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(normalizedValue)) {
            return 'Please enter a valid number';
          }
        }
        return null;
      },
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                inputTextField('Goal Name', _goalNameController),
                const SizedBox(height: 20),
                inputTextField('Target Amount', _targetAmountController,
                    isNumeric: true),
                const SizedBox(height: 20),
                inputTextField('Current Amount', _currentAmountController,
                    isNumeric: true),
                const SizedBox(height: 20),
                inputTextField('Priority (1-5)', _priorityController,
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
                goalColorPicker(),
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
                goalIconGrid(),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _addGoal,
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
      ),
    );
  }

  Widget goalColorPicker() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _goalColorOptions.map((color) {
          return GestureDetector(
            onTap: () => _onColorSelected(color),
            child: Container(
              width: 30,
              height: 30,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(15),
                border: _selectedGoalColor == color
                    ? Border.all(color: Colors.white, width: 3)
                    : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget goalIconGrid() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 4,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        ..._goalIconOptions.map((iconData) {
          return GestureDetector(
            onTap: () => _onIconSelected(iconData),
            child: Container(
              decoration: BoxDecoration(
                color: _selectedGoalIcon == iconData
                    ? (_selectedGoalColor ?? const Color(0xFF191E29))
                    : const Color(0xFF191E29),
                borderRadius: BorderRadius.circular(15),
                border: _selectedGoalIcon == iconData
                    ? Border.all(color: Colors.white, width: 3)
                    : null,
              ),
              child: Center(
                child: Icon(
                  iconData,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
