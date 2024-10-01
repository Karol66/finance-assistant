import 'package:flutter/material.dart';

class TransfersView extends StatefulWidget {
  const TransfersView({Key? key}) : super(key: key);

  @override
  _TransfersViewState createState() => _TransfersViewState();
}

class _TransfersViewState extends State<TransfersView> {
  bool isExpenses = true;

  List<Map<String, dynamic>> transfers = [
    {
      "id": 1,
      "amount": 150.75,
      "transfer_date": "2023-10-01 12:30:00",
      "description": "Grocery Shopping",
      "account_id": 1,
      "category_id": 1,
      "type": "Expenses", // Typ transakcji
    },
    {
      "id": 2,
      "amount": 500.00,
      "transfer_date": "2023-09-28 10:15:00",
      "description": "Salary",
      "account_id": 2,
      "category_id": 2,
      "type": "Income", // Typ transakcji
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF132D46), // Ciemne tło aplikacji
      body: Column(
        children: [
          // Przełączniki Expenses i Income
          Row(
            children: [
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
                  .length,
              itemBuilder: (context, index) {
                final filteredTransfers = transfers
                    .where((transfer) =>
                        transfer['type'] ==
                        (isExpenses ? 'Expenses' : 'Income'))
                    .toList();
                final transfer = filteredTransfers[index];
                return _buildTransferItem(transfer);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget dla pojedynczego transferu
  Widget _buildTransferItem(Map<String, dynamic> transfer) {
    final isExpense = transfer['type'] == 'Expenses';
    final amountText = isExpense
        ? '-\$${transfer['amount'].toStringAsFixed(2)}'
        : '+\$${transfer['amount'].toStringAsFixed(2)}';

    return Card(
      color: const Color(0xFF191E29), // Dark card color
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Data transferu
            Text(
              "Date: ${transfer['transfer_date']}",
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            // Kwota
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  amountText,
                  style: TextStyle(
                    color: isExpense ? Colors.red : Colors.green,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Opis transferu
                Text(
                  transfer['description'],
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // ID konta i kategorii
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Account ID: ${transfer['account_id']}",
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
                Text(
                  "Category ID: ${transfer['category_id']}",
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
    );
  }
}
