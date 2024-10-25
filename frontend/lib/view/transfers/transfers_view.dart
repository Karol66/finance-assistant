import 'package:flutter/material.dart';
import 'package:frontend/services/transfers_service.dart';
import 'package:frontend/view/transfers/transfers_create_view.dart';
import 'package:frontend/view/transfers/transfers_manage_view.dart';

class TransfersView extends StatefulWidget {
  const TransfersView({super.key});

  @override
  _TransfersViewState createState() => _TransfersViewState();
}

class _TransfersViewState extends State<TransfersView> {
  bool isGeneral = true;
  bool isExpenses = true;
  List<Map<String, dynamic>> transfers = [];
  final TransfersService _transfersService = TransfersService();

  @override
  void initState() {
    super.initState();
    loadTransfers(); // Pobieranie transferów z serwisu
  }

  Future<void> loadTransfers() async {
    final fetchedTransfers = await _transfersService.fetchTransfers();
    if (fetchedTransfers != null) {
      setState(() {
        transfers = fetchedTransfers.map((transfer) {
          return {
            "id": transfer['id'],
            "transfer_name": transfer['transfer_name'],
            "amount": transfer['amount'],
            "transfer_date": DateTime.parse(transfer['date']),
            "description": transfer['description'],
            "account_name": transfer['account_name'],
            "account_type": transfer['account_type'],
            "category_name": transfer['category_name'],
            "category_icon": transfer['category_icon'],
            "category_color": _parseColor(transfer['category_color']),
            "type":
                transfer['category_type'] == 'expense' ? 'Expenses' : 'Income',
          };
        }).toList();
      });
    } else {
      print("Failed to load transfers.");
    }
  }

  // Funkcja konwertująca kolor HEX na obiekt Color
  Color _parseColor(String colorString) {
    return Color(
        int.parse(colorString.substring(1, 7), radix: 16) + 0xFF000000);
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF132D46),
      appBar: AppBar(
        title: const Text('Transfer History'),
        backgroundColor: const Color(0xFF0B6B3A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          // Dodany wybór trybu General/Expenses/Income
          Row(
            children: [
              const SizedBox(height: 60),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isGeneral = true;
                      isExpenses = false;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isGeneral ? Colors.white : Colors.transparent,
                          width: 2.0,
                        ),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "General",
                      style: TextStyle(
                        color: isGeneral ? Colors.white : Colors.grey[600],
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
                      isGeneral = false;
                      isExpenses = true;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: !isGeneral && isExpenses
                              ? Colors.white
                              : Colors.transparent,
                          width: 2.0,
                        ),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Expenses",
                      style: TextStyle(
                        color: !isGeneral && isExpenses
                            ? Colors.white
                            : Colors.grey[600],
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
                      isGeneral = false;
                      isExpenses = false;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: !isGeneral && !isExpenses
                              ? Colors.white
                              : Colors.transparent,
                          width: 2.0,
                        ),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Income",
                      style: TextStyle(
                        color: !isGeneral && !isExpenses
                            ? Colors.white
                            : Colors.grey[600],
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _filteredTransfers().length + 1,
              itemBuilder: (context, index) {
                final filteredTransfers = _filteredTransfers();
                if (index == filteredTransfers.length) {
                  return createAddButton();
                }
                final transfer = filteredTransfers[index];
                return transferItem(transfer);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Filtrowanie danych w zależności od wybranego trybu (General, Expenses, Income)
  List<Map<String, dynamic>> _filteredTransfers() {
    if (isGeneral) {
      return transfers;
    } else if (isExpenses) {
      return transfers
          .where((transfer) => transfer['type'] == 'Expenses')
          .toList();
    } else {
      return transfers
          .where((transfer) => transfer['type'] == 'Income')
          .toList();
    }
  }

  Widget transferItem(Map<String, dynamic> transfer) {
    double amount = double.tryParse(transfer['amount'].toString()) ?? 0.0;
    final isExpense = transfer['type'] == 'Expenses';
    final amountText = isExpense
        ? '-\$${amount.abs().toStringAsFixed(2)}'
        : '+\$${amount.toStringAsFixed(2)}';

    String formattedDate = _formatDate(transfer['transfer_date']);

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TransfersManageView(transferId: transfer["id"]),
          ),
        );
        if (result == true) {
          loadTransfers();
        }
      },
      child: Card(
        color: const Color(0xFF191E29),
        margin: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: transfer['category_color'],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    IconData(int.parse(transfer['category_icon']),
                        fontFamily: 'MaterialIcons'),
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Date: $formattedDate",
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      transfer['description'],
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                    const SizedBox(height: 5),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Account: ${transfer['account_name']} (${transfer['account_type']})",
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 12),
                        ),
                        Text(
                          "Category: ${transfer['category_name']}",
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Center(
                child: Text(
                  amountText,
                  style: TextStyle(
                      color: isExpense ? Colors.red : Colors.green,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget createAddButton() {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TransfersCreateView(),
          ),
        );
        if (result == true) {
          loadTransfers();
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF01C38D),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 32, color: Colors.white),
            SizedBox(width: 10),
            Text(
              "Create New Transfer",
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
