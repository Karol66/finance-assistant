import 'package:flutter/material.dart';

class AccountsCreateView extends StatefulWidget {
  const AccountsCreateView({super.key});

  @override
  _AccountsCreateViewState createState() => _AccountsCreateViewState();
}

class _AccountsCreateViewState extends State<AccountsCreateView> {
  final TextEditingController _accountNameController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();
  final TextEditingController _currencyController = TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();

  String? _accountType; 

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
  ];

  void _onColorSelected(Color color) {
    setState(() {
      _selectedColor = color;
    });
  }

  void _onIconSelected(IconData icon) {
    setState(() {
      _selectedIcon = icon;

      if (_selectedColor == null) {
        _selectedColor = const Color(0xFF191E29); 
      }
    });
  }

  void _goToNextPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Scaffold(
          body: Center(child: Text("Next Page")),
        ),
      ),
    );
  }

  Widget inputTextField(
      String hintText, bool obscureText, TextEditingController controller) {
    return TextField(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF132D46),
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: const Color.fromARGB(255, 0, 141, 73),
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

              inputTextField('Currency', false, _currencyController),
              const SizedBox(height: 20),

              inputTextField('Account Number', false, _accountNumberController),
              const SizedBox(height: 20),

              SingleChildScrollView(
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
              ),
              const SizedBox(height: 20),

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
                  }).toList(),

                  moreButton(),
                ],
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _goToNextPage, 
                  style: ElevatedButton.styleFrom(
                    fixedSize:
                        const Size.fromHeight(58), 
                    backgroundColor:
                        const Color(0xFF01C38D), 
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8), 
                    ),
                  ),
                  child: const Text(
                    'Add', 
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
