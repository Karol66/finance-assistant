import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/services/transfers_service.dart';
import 'package:frontend/services/categories_service.dart';
import 'package:frontend/services/accounts_service.dart';

class RegularTransfersCreateView extends StatefulWidget {
  const RegularTransfersCreateView({super.key});

  @override
  _RegularTransfersCreateViewState createState() =>
      _RegularTransfersCreateViewState();
}

class _RegularTransfersCreateViewState
    extends State<RegularTransfersCreateView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _transferNameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TransfersService _transfersService = TransfersService();

  Map<String, dynamic>? _selectedCategory;
  Map<String, dynamic>? _selectedAccount;
  String? _selectedInterval;

  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _accounts = [];
  bool isExpenses = true;

  final CategoriesService _categoriesService = CategoriesService();
  final AccountsService _accountsService = AccountsService();

  final List<String> _intervals = ['daily', 'weekly', 'monthly', 'yearly'];

  @override
  void initState() {
    super.initState();
    loadCategories();
    loadAccounts();
  }

  Future<void> loadCategories() async {
    final fetchedCategories = await _categoriesService.fetchCategories();
    if (fetchedCategories != null) {
      setState(() {
        _categories = fetchedCategories
            .where((category) =>
                category["category_type"] ==
                (isExpenses ? "expense" : "income"))
            .map((category) => {
                  "category_id": category["id"],
                  "category_name": category["category_name"],
                  "category_color": _parseColor(category["category_color"]),
                  "category_icon":
                      _getIconFromString(category["category_icon"]),
                })
            .toList();
      });
    }
  }

  Future<void> loadAccounts() async {
    final fetchedAccounts = await _accountsService.fetchAllAccounts();
    if (fetchedAccounts != null) {
      setState(() {
        _accounts = fetchedAccounts
            .map((account) => {
                  "account_id": account["id"],
                  "account_name": account["account_name"],
                  "account_balance": account["balance"],
                  "account_color": _parseColor(account["account_color"]),
                  "account_icon": _getIconFromString(account["account_icon"]),
                })
            .toList();
      });
    }
  }

  Future<void> _submitRegularTransfer() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedAccount == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select an account.")),
        );
        return;
      }
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a category.")),
        );
        return;
      }
      if (_selectedInterval == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select an interval.")),
        );
        return;
      }

      String transferName = _transferNameController.text;
      String amount = _amountController.text;
      String description = _descriptionController.text;
      int accountId = _selectedAccount!['account_id'];
      int categoryId = _selectedCategory!['category_id'];

      await _transfersService.createRegularTransfer(
        transferName,
        amount,
        description,
        accountId,
        categoryId,
        _selectedInterval!,
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
      validator: (value) {
        if (value == null) {
          return 'Please select an account';
        }
        return null;
      },
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
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCategory = category;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: category["category_color"],
              borderRadius: BorderRadius.circular(15),
              border: _selectedCategory == category
                  ? Border.all(color: Colors.white, width: 3)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(category["category_icon"], size: 30, color: Colors.white),
                const SizedBox(height: 5),
                Text(
                  category["category_name"],
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget intervalDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedInterval,
      items: _intervals.map((interval) {
        return DropdownMenuItem(
          value: interval,
          child: Text(interval[0].toUpperCase() + interval.substring(1)),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedInterval = newValue;
        });
      },
      decoration: InputDecoration(
        labelText: 'Interval',
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget expenseIncomeSwitch() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                isExpenses = true;
                loadCategories();
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isExpenses ? Colors.white : Colors.transparent,
                    width: 2.0,
                  ),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                "Expenses",
                style: TextStyle(
                  color: isExpenses ? Colors.white : Colors.grey[600],
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                isExpenses = false;
                loadCategories();
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: !isExpenses ? Colors.white : Colors.transparent,
                    width: 2.0,
                  ),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                "Income",
                style: TextStyle(
                  color: !isExpenses ? Colors.white : Colors.grey[600],
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF132D46),
      appBar: AppBar(
        title: const Text('Create Regular Transfer'),
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
                inputTextField('Name', _transferNameController),
                const SizedBox(height: 20),
                inputTextField('Amount', _amountController, isNumeric: true),
                const SizedBox(height: 20),
                inputTextField('Description', _descriptionController),
                const SizedBox(height: 20),
                intervalDropdown(),
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
                const Text(
                  'Select Category:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                expenseIncomeSwitch(),
                const SizedBox(height: 10),
                categoryGrid(),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitRegularTransfer,
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size.fromHeight(58),
                      backgroundColor: const Color(0xFF01C38D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Add Regular Transfer',
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
