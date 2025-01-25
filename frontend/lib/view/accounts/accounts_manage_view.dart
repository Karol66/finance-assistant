import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/services/accounts_service.dart';

class AccountsManageView extends StatefulWidget {
  final int accountId;

  const AccountsManageView({super.key, required this.accountId});

  @override
  _AccountsManageViewState createState() => _AccountsManageViewState();
}

class _AccountsManageViewState extends State<AccountsManageView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _accountNameController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();
  final AccountsService _accountsService = AccountsService();

  Color? _selectedColor;
  IconData? _selectedIcon;

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

  @override
  void initState() {
    super.initState();
    _loadAccount();
  }

  Future<void> _loadAccount() async {
    final fetchedAccount =
        await _accountsService.fetchAccountById(widget.accountId);
    if (fetchedAccount != null) {
      setState(() {
        _accountNameController.text = fetchedAccount['account_name'];
        _balanceController.text = fetchedAccount['balance'].toString();
        _selectedColor = _parseColor(fetchedAccount['account_color']);
        _selectedIcon = _getIconFromString(fetchedAccount['account_icon']);
      });
    }
  }

  Future<void> _updateAccount() async {
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
      String balance = _balanceController.text.replaceAll(',', '.');
      String accountColor =
          '#${_selectedColor?.value.toRadixString(16).substring(2, 8)}';
      String accountIcon = _selectedIcon!.codePoint.toString();

      await _accountsService.updateAccount(
        widget.accountId,
        accountName,
        balance,
        accountColor,
        accountIcon,
      );

      Navigator.pop(context, true);
    }
  }

  Future<void> _deleteAccount() async {
    await _accountsService.deleteAccount(widget.accountId);
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

  Widget inputTextField(String hintText, TextEditingController controller,
      {bool isNumeric = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumeric
          ? const TextInputType.numberWithOptions(decimal: true, signed: true)
          : TextInputType.text,
      inputFormatters: isNumeric
          ? [
              FilteringTextInputFormatter.allow(RegExp(r'^-?[0-9.,]*')),
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
          if (!RegExp(r'^-?\d+(\.\d+)?$').hasMatch(normalizedValue)) {
            return 'Please enter a valid number';
          }
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

  Widget iconPicker() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 4,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      physics: const NeverScrollableScrollPhysics(),
      children: _iconOptions.map((iconData) {
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
            child: Icon(iconData, size: 40, color: Colors.white),
          ),
        );
      }).toList(),
    );
  }

  void _onColorSelected(Color color) {
    setState(() {
      _selectedColor = color;
    });
  }

  void _onIconSelected(IconData icon) {
    setState(() {
      _selectedIcon = icon;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF132D46),
      appBar: AppBar(
        title: const Text('Manage Account'),
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
                inputTextField('Account Name', _accountNameController),
                const SizedBox(height: 20),
                inputTextField('Balance', _balanceController, isNumeric: true),
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
                iconPicker(),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _updateAccount,
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size.fromHeight(58),
                      backgroundColor: const Color(0xFF4CAF50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Update Account',
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
                    onPressed: _deleteAccount,
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size.fromHeight(58),
                      backgroundColor: const Color(0xFFF44336),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Delete Account',
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
