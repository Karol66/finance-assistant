import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/services/goals_service.dart';

class GoalsManageView extends StatefulWidget {
  final int goalId;

  const GoalsManageView({super.key, required this.goalId});

  @override
  _GoalsManageViewState createState() => _GoalsManageViewState();
}

class _GoalsManageViewState extends State<GoalsManageView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _goalNameController = TextEditingController();
  final TextEditingController _targetAmountController = TextEditingController();
  final TextEditingController _currentAmountController =
      TextEditingController();
  final TextEditingController _priorityController = TextEditingController();

  IconData? _selectedIcon;
  Color? _selectedColor;

  final GoalsService _goalsService = GoalsService();

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
  ];

  final List<Color> _colorOptions = [
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

  @override
  void initState() {
    super.initState();
    _loadGoal();
  }

  Future<void> _loadGoal() async {
    final fetchedGoal = await _goalsService.fetchGoalById(widget.goalId);

    if (fetchedGoal != null) {
      setState(() {
        _goalNameController.text = fetchedGoal['goal_name'];
        _targetAmountController.text = fetchedGoal['target_amount'].toString();
        _currentAmountController.text =
            fetchedGoal['current_amount'].toString();
        _priorityController.text = fetchedGoal['priority'].toString();
        _selectedColor = _parseColor(fetchedGoal['goal_color']);
        _selectedIcon = _getIconFromString(fetchedGoal['goal_icon']);
      });
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

  void _onIconSelected(IconData icon) {
    setState(() {
      _selectedIcon = icon;
    });
  }

  Future<void> _updateGoal() async {
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

      await _goalsService.updateGoal(
        widget.goalId,
        _goalNameController.text,
        _targetAmountController.text,
        _currentAmountController.text,
        int.parse(_priorityController.text),
        '#${_selectedColor?.value.toRadixString(16).substring(2, 8)}',
        _selectedIcon!.codePoint.toString(),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields correctly.")),
      );
    }
  }

  Future<void> _deleteGoal() async {
    await _goalsService.deleteGoal(widget.goalId);
    Navigator.pop(context, true);
  }

  Widget inputTextField(String hintText, TextEditingController controller,
      {bool isNumeric = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      inputFormatters:
          isNumeric ? [FilteringTextInputFormatter.digitsOnly] : [],
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
        if (isNumeric && !RegExp(r'^\d+$').hasMatch(value)) {
          return 'Please enter a valid number';
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
        title: const Text('Manage Goal'),
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
                colorPicker(),
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
                    onPressed: _updateGoal,
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size.fromHeight(58),
                      backgroundColor: const Color(0xFF4CAF50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Update Goal',
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
                    onPressed: _deleteGoal,
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size.fromHeight(58),
                      backgroundColor: const Color(0xFFF44336),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Delete Goal',
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
                color: _selectedIcon == iconData
                    ? (_selectedColor ?? const Color(0xFF191E29))
                    : const Color(0xFF191E29),
                borderRadius: BorderRadius.circular(15),
                border: _selectedIcon == iconData
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
        moreButton(),
      ],
    );
  }

  Widget moreButton() {
    return GestureDetector(
      onTap: () {
        print("More button pressed");
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFF494E59),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Center(
          child: Icon(
            Icons.more_horiz,
            size: 30,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
