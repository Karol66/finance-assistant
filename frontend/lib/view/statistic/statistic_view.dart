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
  bool isExpenses = false;
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
    String? type;
    if (isGeneral) {
      type = null;
    } else if (isExpenses) {
      type = 'expense';
    } else {
      type = 'income';
    }

    List<Map<String, dynamic>> allTransfers = [];
    DateTime date = selectedDate;

    for (int i = 0; i < 5; i++) {
      final fetchedTransfers = await _transfersService.fetchTransfers(
        period: selectedPeriod.toLowerCase(),
        date: date,
        type: type,
      );

      // if (fetchedTransfers != null) {
      //   allTransfers.addAll(fetchedTransfers.map((transfer) {
      //     return {
      //       "id": transfer['id'],
      //       "transfer_name": transfer['transfer_name'],
      //       "amount": transfer['amount'],
      //       "transfer_date": DateTime.parse(transfer['date']),
      //       "description": transfer['description'],
      //       "account_name": transfer['account_name'],
      //       "account_type": transfer['account_type'],
      //       "category_name": transfer['category_name'],
      //       "category_icon": transfer['category_icon'],
      //       "category_color": _parseColor(transfer['category_color']),
      //       "type":
      //           transfer['category_type'] == 'expense' ? 'Expenses' : 'Income',
      //     };
      //   }).toList());
      // }

      // date = _getPreviousPeriod(date);
    }

    setState(() {
      transfers = allTransfers;
    });
  }

  DateTime _getPreviousPeriod(DateTime date) {
    if (selectedPeriod == 'Day') {
      return date.subtract(const Duration(days: 1));
    } else if (selectedPeriod == 'Week') {
      return date.subtract(const Duration(days: 7));
    } else if (selectedPeriod == 'Month') {
      return DateTime(date.year, date.month - 1, date.day);
    } else {
      return DateTime(date.year - 1, date.month, date.day);
    }
  }

  Color _parseColor(String colorString) {
    return Color(
        int.parse(colorString.substring(1, 7), radix: 16) + 0xFF000000);
  }

  Map<String, List<Map<String, dynamic>>> groupTransfersByDate() {
    Map<String, List<Map<String, dynamic>>> groupedTransfers = {};

    for (var transfer in _filteredTransfers()) {
      DateTime transferDate = transfer['transfer_date'];
      String dateKey;

      if (selectedPeriod == 'Day') {
        dateKey = DateFormat('yyyy-MM-dd').format(transferDate);
      } else if (selectedPeriod == 'Week') {
        DateTime startOfWeek =
            transferDate.subtract(Duration(days: transferDate.weekday - 1));
        dateKey = DateFormat('yyyy-MM-dd').format(startOfWeek);
      } else if (selectedPeriod == 'Month') {
        dateKey = DateFormat('yyyy-MM').format(transferDate);
      } else {
        dateKey = DateFormat('yyyy').format(transferDate);
      }

      groupedTransfers[dateKey] ??= [];
      groupedTransfers[dateKey]!.add(transfer);
    }

    return groupedTransfers;
  }

  List<BarChartGroupData> createBarGroups() {
    List<String> periods = [];
    DateTime date = selectedDate;

    for (int i = 0; i < 5; i++) {
      if (selectedPeriod == 'Year') {
        periods.add(DateFormat('yyyy').format(date));
        date = DateTime(date.year - 1, date.month, date.day);
      } else if (selectedPeriod == 'Month') {
        periods.add(DateFormat('yyyy-MM').format(date));
        date = DateTime(date.year, date.month - 1, date.day);
      } else if (selectedPeriod == 'Week') {
        DateTime startOfWeek = date.subtract(Duration(days: date.weekday - 1));
        periods.add(DateFormat('MMM d').format(startOfWeek));
        date = date.subtract(const Duration(days: 7));
      } else {
        periods.add(DateFormat('MMM d').format(date));
        date = date.subtract(const Duration(days: 1));
      }
    }

    periods = periods.reversed.toList();

    Map<String, List<Map<String, dynamic>>> groupedTransfers =
        groupTransfersByDate();
    List<BarChartGroupData> barGroups = [];

    for (int i = 0; i < periods.length; i++) {
      String period = periods[i];
      List<Map<String, dynamic>> transfersForDate =
          groupedTransfers[period] ?? [];

      double incomeTotal = transfersForDate
          .where((t) => t['type'] == 'Income')
          .fold(0.0, (sum, t) => sum + double.parse(t['amount']));
      double expenseTotal = transfersForDate
          .where((t) => t['type'] == 'Expenses')
          .fold(0.0, (sum, t) => sum + double.parse(t['amount']));
      double netTotal = incomeTotal - expenseTotal;

      List<BarChartRodData> barRods = [];

      if (isGeneral) {
        barRods.add(
            BarChartRodData(toY: incomeTotal, color: Colors.green, width: 11));
        barRods.add(
            BarChartRodData(toY: expenseTotal, color: Colors.red, width: 11));
        barRods.add(BarChartRodData(
          toY: netTotal,
          color: netTotal >= 0 ? Colors.blue : Colors.orange,
          width: 11,
        ));
      } else if (isExpenses) {
        barRods.add(
            BarChartRodData(toY: expenseTotal, color: Colors.red, width: 11));
      } else {
        barRods.add(
            BarChartRodData(toY: incomeTotal, color: Colors.green, width: 11));
      }

      barGroups.add(BarChartGroupData(
        x: i,
        barRods: barRods,
        barsSpace: 6,
      ));
    }

    return barGroups;
  }

double calculateMaxY() {
  List<double> allValues = _filteredTransfers()
      .map((transfer) => double.parse(transfer['amount']))
      .toList();

  double maxY =
      allValues.isNotEmpty ? allValues.reduce((a, b) => a > b ? a : b) : 0;

  double buffer = maxY * 0.5;
  return maxY > 0 ? maxY + buffer : 10;
}


  String getXAxisLabel(double value) {
    int index = value.toInt();

    List<String> periods = [];
    DateTime date = selectedDate;
    for (int i = 0; i < 5; i++) {
      if (selectedPeriod == 'Year') {
        periods.add(DateFormat('yyyy').format(date));
        date = DateTime(date.year - 1, date.month, date.day);
      } else if (selectedPeriod == 'Month') {
        periods.add(DateFormat('MMM yyyy').format(date));
        date = DateTime(date.year, date.month - 1, date.day);
      } else if (selectedPeriod == 'Week') {
        DateTime startOfWeek = date.subtract(Duration(days: date.weekday - 1));
        DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
        periods.add(
            "${DateFormat('d').format(startOfWeek)} - ${DateFormat('d').format(endOfWeek)}");
        date = date.subtract(const Duration(days: 7));
      } else {
        periods.add(DateFormat('MMM d').format(date));
        date = date.subtract(const Duration(days: 1));
      }
    }
    periods = periods.reversed.toList();

    if (index >= 0 && index < periods.length) {
      return periods[index];
    }
    return '';
  }

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
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
                color: Color(0xFF191E29),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
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
                          fontSize: 15,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios,
                            color: Colors.white),
                        onPressed: goToNextPeriod,
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
                              getTitlesWidget: (double value, TitleMeta meta) {
                                return Text(
                                  getXAxisLabel(value),
                                  style: const TextStyle(
                                      color: Colors.white54, fontSize: 12),
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
            const SizedBox(height: 20),
            Row(
              children: [
                _buildTypeSelector("General", isGeneral),
                _buildTypeSelector("Expenses", isExpenses),
                _buildTypeSelector("Income", !isGeneral && !isExpenses),
              ],
            ),
            const SizedBox(height: 20),
            ListView.builder(
              padding: const EdgeInsets.all(10),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _filteredTransfers().length,
              itemBuilder: (context, index) {
                final transfer = _filteredTransfers()[index];
                return transferItem(transfer);
              },
            ),
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
          loadTransfers();
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
              isExpenses = false;
            } else if (type == "Expenses") {
              isGeneral = false;
              isExpenses = true;
            } else {
              isGeneral = false;
              isExpenses = false;
            }
          });
          loadTransfers();
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
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    transfer['description'],
                    style: const TextStyle(color: Colors.white54, fontSize: 16),
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
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
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
    loadTransfers();
  }

  void goToNextPeriod() {
    setState(() {
      if (selectedPeriod == 'Day') {
        selectedDate = selectedDate.add(const Duration(days: 1));
      } else if (selectedPeriod == 'Week') {
        selectedDate = selectedDate.add(const Duration(days: 7));
      } else if (selectedPeriod == 'Month') {
        selectedDate = DateTime(
            selectedDate.year, selectedDate.month + 1, selectedDate.day);
      } else if (selectedPeriod == 'Year') {
        selectedDate = DateTime(
            selectedDate.year + 1, selectedDate.month, selectedDate.day);
      }
    });
    loadTransfers();
  }
}
