import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/services/transfers_service.dart'; // Import serwisu do zaczytywania transferów
import 'package:intl/intl.dart';

class StatisticView extends StatefulWidget {
  const StatisticView({super.key});

  @override
  _StatisticViewState createState() => _StatisticViewState();
}

class _StatisticViewState extends State<StatisticView> {
  bool isGeneral = true;
  bool isExpanses = false;
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

  // Filtrowanie transferów w zależności od wybranego okresu (Year, Month, Week, Day)
  List<Map<String, dynamic>> _filteredTransfers() {
    DateTime now = DateTime.now();
    List<Map<String, dynamic>> filteredTransfers = transfers.where((transfer) {
      DateTime transferDate = DateTime.parse(transfer['transfer_date']);
      if (selectedPeriod == 'Year') {
        return transferDate.year == now.year;
      } else if (selectedPeriod == 'Month') {
        return transferDate.year == now.year && transferDate.month == now.month;
      } else if (selectedPeriod == 'Week') {
        DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return transferDate.isAfter(startOfWeek) && transferDate.isBefore(now.add(Duration(days: 1)));
      } else if (selectedPeriod == 'Day') {
        return transferDate.year == now.year &&
            transferDate.month == now.month &&
            transferDate.day == now.day;
      }
      return true;
    }).toList();

    if (isGeneral) {
      return filteredTransfers; // Wyświetlamy wszystkie transakcje
    } else if (isExpanses) {
      return filteredTransfers
          .where((transfer) => transfer['type'] == 'Expenses')
          .toList(); // Tylko wydatki
    } else {
      return filteredTransfers
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

  // Obliczanie sumy transferów
  double getTotalAmount() {
    double totalIncome = _filteredTransfers()
        .where((transfer) => transfer['type'] == 'Income')
        .fold(0.0, (sum, item) => sum + double.parse(item['amount']));
    double totalExpenses = _filteredTransfers()
        .where((transfer) => transfer['type'] == 'Expenses')
        .fold(0.0, (sum, item) => sum + double.parse(item['amount']));

    if (isGeneral) {
      return totalIncome - totalExpenses;
    } else if (isExpanses) {
      return totalExpenses;
    } else {
      return totalIncome;
    }
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

  // Dane dla wykresu słupkowego na podstawie transferów
  List<BarChartGroupData> createBarGroups() {
    List<double> incomes = _filteredTransfers()
        .where((transfer) => transfer['type'] == 'Income')
        .map((transfer) => double.parse(transfer['amount']))
        .toList();

    List<double> expenses = _filteredTransfers()
        .where((transfer) => transfer['type'] == 'Expenses')
        .map((transfer) => double.parse(transfer['amount']))
        .toList();

    // Obliczamy maksymalną liczbę grup (zakładamy maksymalnie 5 grup na wykresie)
    int maxGroups = 5;
    return List.generate(maxGroups, (index) {
      double incomeValue = index < incomes.length ? incomes[index] : 0;
      double expenseValue = index < expenses.length ? expenses[index] : 0;

      // Jeśli tryb to "General", wyświetl dodatkowy słupek różnicy
      if (isGeneral) {
        double difference = incomeValue - expenseValue;
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: incomeValue,
              color: Colors.green,
              width: 11,
            ),
            BarChartRodData(
              toY: expenseValue,
              color: Colors.red,
              width: 11,
            ),
            BarChartRodData(
              toY: difference,
              color: difference >= 0 ? Colors.blue : Colors.orange,
              width: 11,
            ),
          ],
          barsSpace: 6,
        );
      } else {
        // W trybie "Expenses" lub "Income" wyświetl tylko odpowiedni słupek
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: isExpanses ? expenseValue : incomeValue,
              color: isExpanses ? Colors.red : Colors.green,
              width: 11,
            ),
          ],
          barsSpace: 6,
        );
      }
    });
  }

  double calculateMaxY() {
    List<double> incomes = _filteredTransfers()
        .where((transfer) => transfer['type'] == 'Income')
        .map((transfer) => double.parse(transfer['amount']))
        .toList();

    List<double> expenses = _filteredTransfers()
        .where((transfer) => transfer['type'] == 'Expenses')
        .map((transfer) => double.parse(transfer['amount']))
        .toList();

    double maxIncome = incomes.isNotEmpty ? incomes.reduce((a, b) => a > b ? a : b) : 0;
    double maxExpense = expenses.isNotEmpty ? expenses.reduce((a, b) => a > b ? a : b) : 0;

    // Zwracamy maksymalną wartość na wykresie, z lekką nadwyżką
    return (maxIncome > maxExpense ? maxIncome : maxExpense) + 10;
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF132D46),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Szary element na górze, z wykresem
            Container(
              width: media.width,
              height: 400, // zwiększenie wysokości, aby zmieścić tekst i wykres
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
                    // Wykres słupkowy
                    Expanded(
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: calculateMaxY(), // dynamiczne ustawienie maksymalnej wartości Y
                          barTouchData: BarTouchData(enabled: true),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (double value, TitleMeta meta) {
                                  const style = TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  );
                                  return Text(
                                    'Day ${value.toInt() + 1}',
                                    style: style,
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: createBarGroups(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildTypeSelector("General", isGeneral),
                _buildTypeSelector("Expenses", isExpanses),
                _buildTypeSelector("Income", !isGeneral && !isExpanses),
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
              isExpanses = false;
            } else if (type == "Expenses") {
              isGeneral = false;
              isExpanses = true;
            } else {
              isGeneral = false;
              isExpanses = false;
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
