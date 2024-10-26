import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/services/accounts_service.dart';
import 'package:frontend/services/goals_service.dart';

class GoalsCreateView extends StatefulWidget {
  const GoalsCreateView({super.key});

  @override
  _GoalsCreateViewState createState() => _GoalsCreateViewState();
}

class _GoalsCreateViewState extends State<GoalsCreateView> {
  final TextEditingController _goalNameController = TextEditingController();
  final TextEditingController _targetAmountController = TextEditingController();
  final TextEditingController _currentAmountController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _priorityController = TextEditingController();

  IconData? _selectedGoalIcon;
  Color? _selectedGoalColor;
  String? _selectedStatus;
  Map<String, dynamic>? _selectedAccount;

  final AccountsService _accountsService = AccountsService();
  final GoalsService _goalsService = GoalsService();
  List<Map<String, dynamic>> _accounts = [];

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

  final List<String> _goalStatusOptions = ['active', 'completed', 'cancelled'];
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

  @override
  void initState() {
    super.initState();
    loadAccounts();
  }

  Future<void> loadAccounts() async {
    final fetchedAccounts = await _accountsService.fetchAccounts();
    if (fetchedAccounts != null) {
      setState(() {
        _accounts = fetchedAccounts.map((account) => {
          "account_id": account["id"],
          "account_name": account["account_name"],
          "account_balance": account["balance"],
          "account_color": _parseColor(account["account_color"]),
          "account_icon": _getIconFromString(account["account_icon"]),
        }).toList();
      });
    }
  }

  Future<void> _addGoal() async {
    if (_goalNameController.text.isEmpty ||
        _targetAmountController.text.isEmpty ||
        _currentAmountController.text.isEmpty ||
        _endDateController.text.isEmpty ||
        _selectedStatus == null ||
        _selectedAccount == null ||
        _selectedGoalColor == null ||
        _selectedGoalIcon == null ||
        _priorityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill in all fields.")));
      return;
    }

    await _goalsService.createGoal(
      _goalNameController.text,
      _targetAmountController.text,
      _currentAmountController.text,
      _endDateController.text,
      _selectedStatus!,
      int.parse(_priorityController.text),
      _selectedAccount!['account_id'],
      '#${_selectedGoalColor?.value.toRadixString(16).substring(2, 8)}',
      _selectedGoalIcon!.codePoint.toString(),
    );

    Navigator.pop(context, true);
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

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _endDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
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
        }).toList(),
        moreButton(),
      ],
    );
  }

  Widget accountDropdown() {
    return DropdownButtonFormField<Map<String, dynamic>>(
      value: _selectedAccount,
      itemHeight: 50,
      isDense: false,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF191E29),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
      dropdownColor: const Color(0xFF191E29),
      isExpanded: true,
      icon: const Icon(
        Icons.arrow_drop_down,
        color: Colors.grey,
        size: 30,
      ),
      items: _accounts.map((account) {
        double balance = double.parse(account['account_balance'].toString());
        bool isNegative = balance < 0;
        String balanceText = isNegative
            ? "- \$${balance.abs().toStringAsFixed(2)}"
            : "+ \$${balance.toStringAsFixed(2)}";
        return DropdownMenuItem(
          value: account,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: account['account_color'],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      account['account_icon'],
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    account['account_name'] ?? 'Unknown Account',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
              Text(
                balanceText,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isNegative ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (newAccount) {
        setState(() {
          _selectedAccount = newAccount;
        });
      },
    );
  }

  Widget goalStatusDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedStatus,
      items: _goalStatusOptions.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Text(status[0].toUpperCase() + status.substring(1)),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedStatus = newValue;
        });
      },
      decoration: InputDecoration(
        labelText: 'Goal Status',
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
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
              inputTextField('Target Amount', _targetAmountController,
                  isNumeric: true),
              const SizedBox(height: 20),
              const Text(
                'Select Account:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              accountDropdown(),
              const SizedBox(height: 20),
              inputTextField('Current Amount', _currentAmountController,
                  isNumeric: true),
              const SizedBox(height: 20),
              TextField(
                controller: _endDateController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Select End Date',
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
                onTap: () => _selectEndDate(context),
              ),
              const SizedBox(height: 20),
              goalStatusDropdown(),
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
