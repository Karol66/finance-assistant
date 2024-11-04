import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/services/transfers_service.dart';
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
    loadTransfers();
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
            "type":
                transfer['category_type'] == 'expense' ? 'Expenses' : 'Income',
          };
        }).toList();
      });
    } else {
      print("Failed to load transfers.");
    }
  }

  Color _parseColor(String colorString) {
    return Color(
        int.parse(colorString.substring(1, 7), radix: 16) + 0xFF000000);
  }

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
        return transferDate.isAfter(startOfWeek) &&
            transferDate.isBefore(now.add(const Duration(days: 1)));
      } else if (selectedPeriod == 'Day') {
        return transferDate.year == now.year &&
            transferDate.month == now.month &&
            transferDate.day == now.day;
      }
      return true;
    }).toList();

    if (isGeneral) {
      return filteredTransfers;
    } else if (isExpanses) {
      return filteredTransfers
          .where((transfer) => transfer['type'] == 'Expenses')
          .toList();
    } else {
      return filteredTransfers
          .where((transfer) => transfer['type'] == 'Income')
          .toList();
    }
  }

  String getFormattedPeriod() {
    if (selectedPeriod == 'Day') {
      return DateFormat('EEEE, MMMM d, yyyy').format(selectedDate);
    } else if (selectedPeriod == 'Week') {
      DateTime firstDayOfWeek =
          selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
      DateTime lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 6));
      return "${DateFormat('MMM d').format(firstDayOfWeek)} - ${DateFormat('MMM d').format(lastDayOfWeek)}";
    } else if (selectedPeriod == 'Month') {
      return DateFormat('MMMM yyyy').format(selectedDate);
    } else {
      return DateFormat('yyyy').format(selectedDate);
    }
  }

  void goToPreviousPeriod() {
    setState(() {
      if (selectedPeriod == 'Day') {
        selectedDate = selectedDate.subtract(const Duration(days: 1));
      } else if (selectedPeriod == 'Week') {
        selectedDate = selectedDate.subtract(const Duration(days: 7));
      } else if (selectedPeriod == 'Month') {
        selectedDate = DateTime(
            selectedDate.year, selectedDate.month - 1, selectedDate.day);
      } else if (selectedPeriod == 'Year') {
        selectedDate = DateTime(
            selectedDate.year - 1, selectedDate.month, selectedDate.day);
      }
    });
  }

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

  String _formatDate(String dateTimeString) {
    DateTime parsedDate = DateTime.parse(dateTimeString);
    return "${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}";
  }

  List<BarChartGroupData> createBarGroups() {
    List<double> incomes = _filteredTransfers()
        .where((transfer) => transfer['type'] == 'Income')
        .map((transfer) => double.parse(transfer['amount']))
        .toList();

    List<double> expenses = _filteredTransfers()
        .where((transfer) => transfer['type'] == 'Expenses')
        .map((transfer) => double.parse(transfer['amount']))
        .toList();

    int maxGroups = 5;
    return List.generate(maxGroups, (index) {
      double incomeValue = index < incomes.length ? incomes[index] : 0;
      double expenseValue = index < expenses.length ? expenses[index] : 0;

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

    double maxIncome =
        incomes.isNotEmpty ? incomes.reduce((a, b) => a > b ? a : b) : 0;
    double maxExpense =
        expenses.isNotEmpty ? expenses.reduce((a, b) => a > b ? a : b) : 0;

    return (maxIncome > maxExpense ? maxIncome : maxExpense) + 10;
  }

  String getXAxisLabel(double value) {
    int index = value.toInt();
    if (selectedPeriod == 'Day') {
      return 'Day ${index + 1}';
    } else if (selectedPeriod == 'Week') {
      return 'Week ${index + 1}';
    } else if (selectedPeriod == 'Month') {
      return 'Month ${index + 1}';
    } else if (selectedPeriod == 'Year') {
      return 'Year ${index + 1}';
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF132D46),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: media.width,
              height: 400,
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
                    Row(
                      children: [
                        _buildPeriodSelector("Year"),
                        _buildPeriodSelector("Month"),
                        _buildPeriodSelector("Week"),
                        _buildPeriodSelector("Day"),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios,
                              color: Colors.white),
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
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: calculateMaxY(),
                          barTouchData: BarTouchData(enabled: true),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget:
                                    (double value, TitleMeta meta) {
                                  return Text(
                                    getXAxisLabel(value),
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
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
