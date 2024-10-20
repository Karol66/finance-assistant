import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/services/transfers_service.dart';
import 'package:intl/intl.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  bool isGeneral = true;
  bool isExpenses = false;
  String selectedPeriod = 'Year';
  DateTime selectedDate = DateTime.now();

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
            "transfer_date": transfer['date'],
            "description": transfer['description'],
            "account_name": transfer['account_name'],
            "account_type": transfer['account_type'],
            "category_name": transfer['category_name'],
            "category_icon": transfer['category_icon'],
            "category_color": _parseColor(transfer['category_color']),
            "type": transfer['category_type'] == 'expense' ? 'Expenses' : 'Income',
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

  // Filtrowanie danych w zależności od wybranego trybu (General, Expenses, Income)
  List<Map<String, dynamic>> _filteredTransfers() {
    if (isGeneral) {
      return transfers; // Wyświetlamy wszystkie transakcje
    } else if (isExpenses) {
      return transfers
          .where((transfer) => transfer['type'] == 'Expenses')
          .toList(); // Tylko wydatki
    } else {
      return transfers
          .where((transfer) => transfer['type'] == 'Income')
          .toList(); // Tylko dochody
    }
  }

  // Funkcja formatująca datę w zależności od wybranego okresu
  String getFormattedPeriod() {
    if (selectedPeriod == 'Day') {
      return DateFormat('EEEE, MMMM d, yyyy').format(selectedDate);  // Format dla dnia
    } else if (selectedPeriod == 'Week') {
      DateTime firstDayOfWeek = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
      DateTime lastDayOfWeek = firstDayOfWeek.add(Duration(days: 6));
      return "${DateFormat('MMM d').format(firstDayOfWeek)} - ${DateFormat('MMM d').format(lastDayOfWeek)}"; // Format dla tygodnia
    } else if (selectedPeriod == 'Month') {
      return DateFormat('MMMM yyyy').format(selectedDate);  // Format dla miesiąca
    } else {
      return DateFormat('yyyy').format(selectedDate);  // Format dla roku
    }
  }

  // Funkcja do cofania okresu
  void goToPreviousPeriod() {
    setState(() {
      if (selectedPeriod == 'Day') {
        selectedDate = selectedDate.subtract(const Duration(days: 1));
      } else if (selectedPeriod == 'Week') {
        selectedDate = selectedDate.subtract(const Duration(days: 7));
      } else if (selectedPeriod == 'Month') {
        selectedDate = DateTime(selectedDate.year, selectedDate.month - 1, selectedDate.day);
      } else if (selectedPeriod == 'Year') {
        selectedDate = DateTime(selectedDate.year - 1, selectedDate.month, selectedDate.day);
      }
    });
  }

  // Wyświetlanie pojedynczego elementu transferu
  Widget transferItem(Map<String, dynamic> transfer) {
    double amount = double.tryParse(transfer['amount'].toString()) ?? 0.0;
    final isExpense = transfer['type'] == 'Expenses';
    final amountText = isExpense
        ? '-\$${amount.abs().toStringAsFixed(2)}'
        : '+\$${amount.toStringAsFixed(2)}';

    String formattedDate = _formatDate(transfer['transfer_date']);

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
            // Ikona kategorii
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: transfer['category_color'], // Kolor kategorii
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
            // Dane transferu
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Date: $formattedDate",
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
                        "Account: ${transfer['account_name']} (${transfer['account_type']})",
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        "Category: ${transfer['category_name']}",
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
            // Kwota transferu
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

  // Formatowanie daty, aby wyświetlać tylko dzień
  String _formatDate(String dateTimeString) {
    DateTime parsedDate = DateTime.parse(dateTimeString);
    return "${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}";
  }

  // Obliczanie sumy transferów
  double getTotalAmount() {
    double totalIncome = transfers
        .where((transfer) => transfer['type'] == 'Income')
        .fold(0.0, (sum, item) => sum + double.parse(item['amount']));
    double totalExpenses = transfers
        .where((transfer) => transfer['type'] == 'Expenses')
        .fold(0.0, (sum, item) => sum + double.parse(item['amount']));

    if (isGeneral) {
      return totalIncome - totalExpenses;
    } else if (isExpenses) {
      return totalExpenses;
    } else {
      return totalIncome;
    }
  }

  // Dane dla wykresu kołowego na podstawie transferów
  List<PieChartSectionData> getPieChartData() {
    return _filteredTransfers().map((transfer) {
      double value = double.parse(transfer["amount"]);
      return PieChartSectionData(
        color: transfer["category_color"],
        value: value,
        title: '',
        radius: 30,
        titlePositionPercentageOffset: 0.55,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF132D46),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Sekcja wykresu kołowego
            Container(
              width: media.width,
              height: 415,
              decoration: const BoxDecoration(
                color: Color(0xFF191E29),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Wybór okresu: Year, Month, Week, Day
                    Row(
                      children: [
                        _buildPeriodSelector("Year"),
                        _buildPeriodSelector("Month"),
                        _buildPeriodSelector("Week"),
                        _buildPeriodSelector("Day"),
                      ],
                    ),
                    const SizedBox(height: 10), // Odstęp między wyborem okresu a datą
                    // Dodanie strzałki i pola do zmiany daty
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                          onPressed: goToPreviousPeriod,
                        ),
                        Text(
                          getFormattedPeriod(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              sectionsSpace: 12,
                              centerSpaceRadius: 110,
                              sections: getPieChartData(),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${isExpenses ? '-' : '+'} \$${getTotalAmount().toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: isExpenses ? Colors.red : Colors.green,
                                ),
                              ),
                              Text(
                                isExpenses ? "Total Expenses" : "Total Income",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Wybór typu: General, Expenses, Income
            Row(
              children: [
                _buildTypeSelector("General", isGeneral),
                _buildTypeSelector("Expenses", isExpenses),
                _buildTypeSelector("Income", !isGeneral && !isExpenses),
              ],
            ),
            const SizedBox(height: 20),
            // Lista transferów
            ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _filteredTransfers().length,
              itemBuilder: (context, index) {
                var transfer = _filteredTransfers()[index];
                return transferItem(transfer);
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // Funkcja tworząca widget do wyboru okresu
  Widget _buildPeriodSelector(String period) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedPeriod = period;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selectedPeriod == period
                    ? Colors.white
                    : Colors.transparent,
                width: 2.0,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            period,
            style: TextStyle(
              color: selectedPeriod == period ? Colors.white : Colors.grey,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // Funkcja tworząca widget do wyboru typu (General, Expenses, Income)
  Widget _buildTypeSelector(String type, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (type == "General") {
              isGeneral = true;
              isExpenses = false;
            } else if (type == "Expenses") {
              isGeneral = false;
              isExpenses = true;
            } else {
              isGeneral = false;
              isExpenses = false;
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 2.0,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            type,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
