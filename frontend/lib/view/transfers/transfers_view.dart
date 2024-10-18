import 'package:flutter/material.dart';
import 'package:frontend/services/transfers_service.dart';
import 'package:frontend/view/transfers/transfers_create_view.dart';

class TransfersView extends StatefulWidget {
  const TransfersView({super.key});

  @override
  _TransfersViewState createState() => _TransfersViewState();
}

class _TransfersViewState extends State<TransfersView> {
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
    print('Fetched transfers: $fetchedTransfers'); // Dodaj logowanie

    setState(() {
      transfers = fetchedTransfers.map((transfer) {
        return {
          "id": transfer['id'],
          "transfer_name": transfer['transfer_name'], // Zmiana, aby dopasować do nazwy w modelu
          "amount": transfer['amount'],
          "transfer_date": transfer['date'],
          "description": transfer['description'],
          "account_id": transfer['account'],
          "category_id": transfer['category'],
          "type": transfer['category_type'] == 'expense' ? 'Expenses' : 'Income',
        };
      }).toList();
    });
  } else {
    print("Failed to load transfers.");
  }
}

  void createTransferClick() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TransfersCreateView(),
      ),
    );
  }

  // Funkcja wyszukująca szczegóły kategorii na podstawie category_id (możesz dostosować w zależności od struktury kategorii)
  Map<String, dynamic>? _getCategoryById(int categoryId) {
    return null; // Dodaj tutaj odpowiednią logikę, jeśli kategorie są dostępne
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
          Row(
            children: [
              const SizedBox(height: 60),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isExpenses = true;
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
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: transfers
                      .where((transfer) =>
                          transfer['type'] ==
                          (isExpenses ? 'Expenses' : 'Income'))
                      .length + 1,
              itemBuilder: (context, index) {
                final filteredTransfers = transfers
                    .where((transfer) =>
                        transfer['type'] ==
                        (isExpenses ? 'Expenses' : 'Income'))
                    .toList();
                if (index == filteredTransfers.length) {
                  return _buildCreateNewTransferButton();
                }
                final transfer = filteredTransfers[index];
                return _buildTransferItem(transfer);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateNewTransferButton() {
    return GestureDetector(
      onTap: createTransferClick,
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
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferItem(Map<String, dynamic> transfer) {
    final isExpense = transfer['type'] == 'Expenses';
    final amountText = isExpense
        ? '-\$${transfer['amount'].toStringAsFixed(2)}'
        : '+\$${transfer['amount'].toStringAsFixed(2)}';

    // Pobieramy dane kategorii dla danego transferu
    final category = _getCategoryById(transfer['category_id']);

    return Card(
      color: const Color(0xFF191E29),
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Wyśrodkowana ikona kategorii
            if (category != null)
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: category['category_color'],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    category['category_icon'],
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            const SizedBox(width: 15), // Odstęp między ikoną a tekstem

            // Data, Opis, Konto i Kategoria
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Date: ${transfer['transfer_date']}",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    transfer['description'],
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Account: ${transfer['account_id'] == 1 ? 'Main Account' : 'Secondary Account'}",
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        "Category: ${category != null ? category['category_name'] : 'Unknown'}",
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Wyśrodkowana kwota
            Center(
              child: Text(
                amountText,
                style: TextStyle(
                  color: isExpense ? Colors.red : Colors.green,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
