import 'package:flutter/material.dart';
import 'package:frontend/services/accounts_service.dart';

class AccountsCreateView extends StatefulWidget {
  const AccountsCreateView({super.key});

  @override
  _AccountsCreateViewState createState() => _AccountsCreateViewState();
}

class _AccountsCreateViewState extends State<AccountsCreateView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _accountNameController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();
  final AccountsService _accountsService = AccountsService();

  String _accountType = 'Savings';
  Color? _selectedColor;
  IconData? _selectedIcon;

  final List<String> _accountTypes = [
    'Savings',
    'Checking',
    'Credit Card',
    'Investment',
  ];

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

  Future<void> _addAccount() async {
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

      String accountName = _accountNameController.text;
      String balance = double.parse(_balanceController.text).toStringAsFixed(2);
      String categoryColor = '#${_selectedColor?.value.toRadixString(16).substring(2, 8)}';
      String accountIcon = _selectedIcon != null
          ? _selectedIcon!.codePoint.toString()
          : 'default_icon';

      await _accountsService.createAccount(
        accountName,
        _accountType,
        balance,
        categoryColor,
        accountIcon,
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields correctly.")),
      );
    }
  }

  void _onColorSelected(Color color) {
    setState(() {
      _selectedColor = color;
    });
  }

  void _onIconSelected(IconData icon) {
    setState(() {
      _selectedIcon = icon;
      _selectedColor ??= const Color(0xFF191E29);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF132D46),
      appBar: AppBar(
        title: const Text('Create Account'),
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
                inputTextField('Account Name', false, _accountNameController),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _accountType,
                  items: _accountTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _accountType = value!;
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    hintText: 'Account Type',
                  ),
                ),
                const SizedBox(height: 20),
                inputTextField('Balance', false, _balanceController),
                const SizedBox(height: 20),
                const Text(
                  'Select Account Color:',
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
                  'Select Account Icon:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    ..._iconOptions.map((iconData) {
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
                          child: Icon(
                            iconData,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _addAccount,
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size.fromHeight(58),
                      backgroundColor: const Color(0xFF01C38D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Add Account',
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

  Widget inputTextField(
      String hintText, bool obscureText, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
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
}
