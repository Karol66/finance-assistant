import 'package:flutter/material.dart';
import 'package:frontend/services/transfers_service.dart';
import 'package:frontend/services/categories_service.dart';
import 'package:frontend/services/accounts_service.dart';
import 'package:intl/intl.dart';

class TransfersManageView extends StatefulWidget {
  final int transferId;

  const TransfersManageView({super.key, required this.transferId});

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

  final CategoriesService _categoriesService = CategoriesService();
  final AccountsService _accountsService = AccountsService();

  @override
  void initState() {
    super.initState();
    _loadData(); // Load data asynchronously
  }

  Future<void> _loadData() async {
    await Future.wait([
      loadAccounts(),
      loadCategories(),
    ]);

    // Teraz ładujemy szczegóły transferu
    await _loadTransfer();

    setState(() {
      // Zaktualizowane dane już wczytane do list rozwijanych
    });
  }

  Future<void> _loadTransfer() async {
    final fetchedTransfer =
        await _transfersService.fetchTransferById(widget.transferId);

    if (fetchedTransfer != null) {
      final fetchedCategory =
          await _transfersService.fetchCategoryFromTransfer(widget.transferId);
      final fetchedAccount =
          await _transfersService.fetchAccountFromTransfer(widget.transferId);

      setState(() {
        _transferNameController.text = fetchedTransfer['transfer_name'];
        _amountController.text = fetchedTransfer['amount'].toString();
        _descriptionController.text = fetchedTransfer['description'];
        _selectedDate = DateTime.parse(fetchedTransfer['date']);
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);

        // Ustawienie wybranej kategorii
        if (fetchedCategory != null) {
          _selectedCategory = _categories.firstWhere(
            (category) => category['category_id'] == fetchedCategory['id'],
            orElse: () => _categories.isNotEmpty ? _categories.first : {},
          );
        }

        // Ustawienie wybranego konta
        if (fetchedAccount != null) {
          _selectedAccount = _accounts.firstWhere(
            (account) => account['account_id'] == fetchedAccount['id'],
            orElse: () => _accounts.isNotEmpty ? _accounts.first : {},
          );
        }
      });
    }
  }

  Future<void> loadCategories() async {
    final fetchedCategories = await _categoriesService.fetchCategories();
    if (fetchedCategories != null) {
      setState(() {
        _categories = fetchedCategories
            .map((category) => {
                  "category_id": category["id"],
                  "category_name": category["category_name"],
                  "category_icon":
                      category["category_icon"], // Pobieranie ikony
                  "category_color":
                      category["category_color"], // Pobieranie koloru
                })
            .toList();

        if (_selectedCategory == null && _categories.isNotEmpty) {
          _selectedCategory = _categories.first;
        }
      });
    } else {
      print('Failed to load categories');
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
                  "account_icon": account["account_icon"], // Pobieranie ikony
                  "account_color":
                      account["account_color"], // Pobieranie koloru
                  "account_balance": account["balance"], // Pobieranie salda
                })
            .toList();

        if (_selectedAccount == null && _accounts.isNotEmpty) {
          _selectedAccount = _accounts.first;
        }
      });
    }
  }

// Funkcja konwertująca kolor HEX na obiekt Color z obsługą null
  Color _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) {
      return Colors.grey; // Domyślny kolor, jeśli brak danych
    }
    return Color(
        int.parse(colorString.substring(1, 7), radix: 16) + 0xFF000000);
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

// Dropdown for accounts with balance, icon, and dynamic color
Widget accountDropdown() {
  return DropdownButtonFormField<Map<String, dynamic>>(
    value: _selectedAccount,
    itemHeight: 50, // Ustawienie wysokości każdego elementu dropdown
    isDense: false, // Zapewnienie większej przestrzeni dla wybranego elementu
    decoration: InputDecoration(
      filled: true,
      fillColor: const Color(0xFF191E29), // Dopasowane tło jak w widoku konta
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0), // Zwiększenie marginesu wewnętrznego
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    ),
    dropdownColor: const Color(0xFF191E29), // Kolor rozwijanego menu
    isExpanded: true,
    icon: const Icon(
      Icons.arrow_drop_down,
      color: Colors.grey,
      size: 30, // Zwiększenie rozmiaru strzałki
    ), 
    items: _accounts.map((account) {
      double balance = double.parse(account['account_balance'].toString());
      bool isNegative = balance < 0;
      String balanceText = isNegative
          ? "- \$${balance.abs().toStringAsFixed(2)}"
          : "+ \$${balance.toStringAsFixed(2)}";
      return DropdownMenuItem(
        value: account,
        child: SizedBox(
          height: 60, // Zwiększenie wysokości elementu w menu rozwijanym
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40, // Szerokość ikony
                    height: 40  , // Wysokość ikony (równa, aby było koło)
                    decoration: BoxDecoration(
                      color: _parseColor(account['account_color'] as String?), // Dynamic color for account
                      borderRadius: BorderRadius.circular(25), // Idealnie zaokrąglona ikona
                    ),
                    child: Center(
                      child: Icon(
                        IconData(
                          int.parse(account['account_icon']),
                          fontFamily: 'MaterialIcons',
                        ),
                        color: Colors.white,
                        size: 24, // Rozmiar ikony
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    account['account_name'] ?? 'Unknown Account',
                    style: const TextStyle(
                      fontSize: 18, // Rozmiar tekstu
                      color: Colors.white54, // Tekst w stylu widoku konta
                    ),
                  ),
                ],
              ),
              Text(
                balanceText,
                style: TextStyle(
                  fontSize: 18, // Rozmiar tekstu
                  fontWeight: FontWeight.bold,
                  color: isNegative ? Colors.red : Colors.green, // Kolor na podstawie wartości
                ),
              ),
            ],
          ),
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

// Dropdown for categories with dynamic icon and color
Widget categoryDropdown() {
  return DropdownButtonFormField<Map<String, dynamic>>(
    value: _selectedCategory,
    itemHeight: 50, // Wysokość każdego elementu dropdown
    isDense: false, // Zapewnienie większej przestrzeni dla wybranego elementu
    decoration: InputDecoration(
      filled: true,
      fillColor: const Color(0xFF191E29), // Dopasowane tło jak w widoku konta
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0), // Zwiększenie marginesu wewnętrznego
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    ),
    dropdownColor: const Color(0xFF191E29), // Kolor rozwijanego menu
    isExpanded: true,
    icon: const Icon(
      Icons.arrow_drop_down,
      color: Colors.grey,
      size: 30, // Zwiększenie rozmiaru strzałki
    ),
    items: _categories.map((category) {
      return DropdownMenuItem(
        value: category,
        child: SizedBox(
          height: 60, // Zwiększenie wysokości elementu w menu rozwijanym
          child: Row(
            children: [
              Container(
                width: 40, // Szerokość ikony
                height: 40, // Wysokość ikony (równa, aby było koło)
                decoration: BoxDecoration(
                  color: _parseColor(category['category_color'] as String?), // Dynamic color for category
                  borderRadius: BorderRadius.circular(25), // Idealnie zaokrąglona ikona
                ),
                child: Center(
                  child: Icon(
                    IconData(
                      int.parse(category['category_icon']),
                      fontFamily: 'MaterialIcons',
                    ),
                    color: Colors.white,
                    size: 24, // Rozmiar ikony
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Text(
                category['category_name'] ?? 'Unknown Category',
                style: const TextStyle(
                  fontSize: 18, // Rozmiar tekstu
                  color: Colors.white54, // Tekst w stylu widoku konta
                ),
              ),
            ],
          ),
        ),
      );
    }).toList(),
    onChanged: (newCategory) {
      setState(() {
        _selectedCategory = newCategory ?? _categories.first;
      });
    },
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
              categoryDropdown(),
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
