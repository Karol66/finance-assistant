import 'package:flutter/material.dart';
import 'package:frontend/services/transfers_service.dart';
import 'package:frontend/services/categories_service.dart';
import 'package:frontend/services/accounts_service.dart';
import 'package:intl/intl.dart';

class TransfersManageView extends StatefulWidget {
  final int transferId;

  const TransfersManageView({Key? key, required this.transferId})
      : super(key: key);

  @override
  _TransfersManageViewState createState() => _TransfersManageViewState();
}

class _TransfersManageViewState extends State<TransfersManageView> {
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

  @override
  void initState() {
    super.initState();
    _loadData(); // Ładujemy dane asynchronicznie
  }

  Future<void> _loadData() async {
    await Future.wait([
      loadAccounts(), // Ładujemy konta
      loadCategories(), // Ładujemy kategorie
      _loadTransfer(), // Ładujemy transfer
    ]);

    // Po załadowaniu wszystkiego sprawdzamy, czy dane są gotowe
    setState(() {
      // Ustawiamy _selectedAccount tylko jeśli konta są załadowane
      if (_accounts.isNotEmpty && _selectedAccount == null) {
        _selectedAccount = _accounts.firstWhere(
          (account) => account['account_id'] == _selectedAccount?['account_id'],
          orElse: () => _accounts.first,
        );
      }
    });
  }

  Future<void> _loadTransfer() async {
    final fetchedTransfer =
        await _transfersService.fetchTransferById(widget.transferId);
    if (fetchedTransfer != null) {
      setState(() {
        _transferNameController.text = fetchedTransfer['transfer_name'];
        _amountController.text = fetchedTransfer['amount'].toString();
        _descriptionController.text = fetchedTransfer['description'];
        _selectedDate = DateTime.parse(fetchedTransfer['date']);
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);

        // Ustawienie wybranego konta po pierwszym załadowaniu
        _selectedAccount = _accounts.firstWhere(
          (account) => account['account_id'] == fetchedTransfer['account_id'],
          orElse: () => _accounts.isNotEmpty
              ? _accounts.first
              : {}, // Wybierz pierwsze dostępne konto, jeśli nie znaleziono
        );

        // Ustawienie wybranej kategorii po pierwszym załadowaniu
        _selectedCategory = _categories.firstWhere(
          (category) =>
              category['category_id'] == fetchedTransfer['category_id'],
          orElse: () => _categories.isNotEmpty
              ? _categories.first
              : {}, // Wybierz pierwszą dostępną kategorię, jeśli nie znaleziono
        );

        isExpenses = fetchedTransfer['category_type'] == 'expense';
      });
    }
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

        // Ustawienie pierwszej kategorii jako domyślnie wybranej, jeśli nie ma wybranej
        if (_selectedCategory == null && _categories.isNotEmpty) {
          _selectedCategory = _categories.first;
        }
      });
    }
  }

  Future<void> loadAccounts() async {
    final fetchedAccounts = await _accountsService.fetchAccounts();
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

        // Jeśli nie ustawiono wcześniej konta, ustaw pierwsze konto
        if (_selectedAccount == null && _accounts.isNotEmpty) {
          _selectedAccount = _accounts.firstWhere(
            (account) =>
                account['account_id'] == _selectedAccount?['account_id'],
            orElse: () => _accounts.first,
          );
        }
      });
    }
  }

  Future<void> _updateTransfer() async {
    if (_transferNameController.text.isEmpty ||
        _amountController.text.isEmpty ||
        _selectedAccount == null ||
        _selectedCategory == null ||
        _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill in all fields.")));
      return;
    }

    String transferName = _transferNameController.text;
    String amount = _amountController.text;
    String description = _descriptionController.text;
    String date = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    int accountId = _selectedAccount!['account_id'];
    int categoryId = _selectedCategory!['category_id'];

    await _transfersService.updateTransfer(widget.transferId, transferName,
        amount, description, date, accountId, categoryId);

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Transfer updated successfully!")));
    Navigator.pop(context, true);
  }

  Future<void> _deleteTransfer() async {
    await _transfersService.deleteTransfer(widget.transferId);
    Navigator.pop(context, true);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
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
        suffixIcon: const Icon(
          Icons.calendar_today,
          color: Color(0xFF494E59),
        ),
      ),
      onTap: () => _selectDate(context),
    );
  }

  Widget accountsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _accounts.length,
      itemBuilder: (context, index) {
        final account = _accounts[index];
        // Porównaj ID konta, zamiast całego obiektu
        bool isSelected =
            _selectedAccount?['account_id'] == account['account_id'];

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedAccount = account;
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF191E29),
              borderRadius: BorderRadius.circular(15),
              // Ustawienie obramowania dla wybranego konta
              border:
                  isSelected ? Border.all(color: Colors.white, width: 3) : null,
            ),
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
                      child: Icon(account['account_icon'],
                          size: 20, color: Colors.white),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      account['account_name'],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
                Text(
                  "\+ \$${double.parse(account['account_balance'].toString()).toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: double.parse(account['account_balance']) < 0
                        ? Colors.red
                        : Colors.green,
                  ),
                ),
              ],
            ),
          ),
        );
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
        bool isSelected =
            _selectedCategory?['category_id'] == category['category_id'];

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCategory = category;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: category['category_color'],
              borderRadius: BorderRadius.circular(15),
              border:
                  isSelected ? Border.all(color: Colors.white, width: 3) : null,
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
                    fontWeight: FontWeight.bold,
                  ),
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
        title: const Text('Manage Transfer'),
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
              inputTextField('Transfer Name', _transferNameController),
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
              accountsList(),
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
                  onPressed: _updateTransfer,
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size.fromHeight(58),
                    backgroundColor: const Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Update Transfer',
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
                  onPressed: _deleteTransfer,
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size.fromHeight(58),
                    backgroundColor: const Color(0xFFF44336),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Delete Transfer',
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
