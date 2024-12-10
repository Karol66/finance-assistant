import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/services/transfers_service.dart';
import 'package:intl/intl.dart';
import 'package:frontend/services/categories_service.dart';
import 'package:frontend/services/accounts_service.dart';

class TransfersCreateView extends StatefulWidget {
  const TransfersCreateView({super.key});

  @override
  _TransfersCreateViewState createState() => _TransfersCreateViewState();
}

class _TransfersCreateViewState extends State<TransfersCreateView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _transferNameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TransfersService _transfersService = TransfersService();

  DateTime? _selectedDate;
  Map<String, dynamic>? _selectedCategory;
  Map<String, dynamic>? _selectedAccount;
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _accounts = [];
  bool isExpenses = true;

  final CategoriesService _categoriesService = CategoriesService();
  final AccountsService _accountsService = AccountsService();

  Future<void> _submitTransfer() async {
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
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a date.")),
        );
        return;
      }

      String transferName = _transferNameController.text;
      String amount = _amountController.text;
      String description = _descriptionController.text;
      String date = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      int accountId = _selectedAccount!['account_id'];
      int categoryId = _selectedCategory!['category_id'];

      await _transfersService.createTransfer(
          transferName, amount, description, date, accountId, categoryId);

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields correctly.")),
      );
    }
  }

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

  IconData _getIconFromString(String iconString) {
    int codePoint = int.tryParse(iconString) ?? 0;
    return IconData(codePoint, fontFamily: 'MaterialIcons');
  }

  Color _parseColor(String colorString) {
    return Color(
        int.parse(colorString.substring(1, 7), radix: 16) + 0xFF000000);
  }

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
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Widget inputTextField(String hintText, TextEditingController controller,
      {bool isNumeric = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumeric
          ? TextInputType.numberWithOptions(decimal: true)
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

  Widget datePickerField(String hintText, TextEditingController controller) {
    return TextFormField(
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
      onTap: () => _selectDate(context),
      validator: (value) {
        if (_selectedDate == null) {
          return 'Please select a date';
        }
        return null;
      },
    );
  }

  Widget accountDropdown() {
    return DropdownButtonFormField<Map<String, dynamic>>(
      value: _selectedAccount,
      itemHeight: null,
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
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
                  Flexible(
                    fit: FlexFit.loose,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account['account_name'] ?? 'Unknown Account',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white54,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          balanceText,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isNegative ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                inputTextField('Name', _transferNameController),
                const SizedBox(height: 20),
                inputTextField('Amount', _amountController, isNumeric: true),
                const SizedBox(height: 20),
                datePickerField('Select Date', _dateController),
                const SizedBox(height: 20),
                inputTextField('Description', _descriptionController),
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
                    onPressed: _submitTransfer,
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size.fromHeight(58),
                      backgroundColor: const Color(0xFF01C38D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
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
      ),
    );
  }
}
