import 'package:flutter/material.dart';
import 'package:frontend/services/transfers_service.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

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
  List<Map<String, dynamic>> chartTransfers = [];

  final TransfersService _transfersService = TransfersService();

  int currentPage = 1;
  bool hasNextPage = true;

  @override
  void initState() {
    super.initState();
    loadTransfers();
    loadAllTransfers();
  }

  Future<void> loadAllTransfers() async {
    String? type;
    if (isGeneral) {
      type = null;
    } else if (isExpenses) {
      type = 'expense';
    } else {
      type = 'income';
    }

    final fetchedTransfers = await _transfersService.fetchAllTransfers(
      period: selectedPeriod.toLowerCase(),
      date: selectedDate,
      type: type,
    );

    if (fetchedTransfers != null) {
      setState(() {
        chartTransfers = fetchedTransfers.map((transfer) {
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
      print("Failed to load transfers for chart.");
    }
  }

  Future<void> loadTransfers({int page = 1}) async {
    String? type;
    if (isGeneral) {
      type = null;
    } else if (isExpenses) {
      type = 'expense';
    } else {
      type = 'income';
    }

    final fetchedTransfers = await _transfersService.fetchTransfers(
      page: page,
      period: selectedPeriod.toLowerCase(),
      date: selectedDate,
      type: type,
    );

    if (fetchedTransfers != null) {
      setState(() {
        transfers = (fetchedTransfers['results'] as List).map((transfer) {
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
        currentPage = page;
        hasNextPage = page < fetchedTransfers['total_pages'];
      });
    } else {
      print("Failed to load transfers.");
    }
  }

  void goToPreviousPage() {
    if (currentPage > 1) {
      loadTransfers(page: currentPage - 1);
    }
  }

  void goToNextPage() {
    if (hasNextPage) {
      loadTransfers(page: currentPage + 1);
    }
  }

  Color _parseColor(String colorString) {
    return Color(
        int.parse(colorString.substring(1, 7), radix: 16) + 0xFF000000);
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
    loadAllTransfers();
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
    loadAllTransfers();
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
              height: 445,
              decoration: const BoxDecoration(
                color: Color(0xFF191E29),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
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
                    Container(
                      width: media.width,
                      height: 300,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: buildBarChart(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isGeneral = true;
                        isExpenses = false;
                      });
                      loadTransfers();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color:
                                isGeneral ? Colors.white : Colors.transparent,
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
                      loadTransfers();
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
                      loadTransfers();
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
            const SizedBox(height: 15),
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
            const SizedBox(height: 10),
            _buildPaginationControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationControls() {
    int totalPages = hasNextPage ? currentPage + 1 : currentPage;

    int startPage = currentPage - 2 > 0 ? currentPage - 2 : 1;
    int endPage = startPage + 4;

    if (endPage > totalPages) {
      endPage = totalPages;
      startPage = endPage - 4 > 0 ? endPage - 4 : 1;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: currentPage > 1 ? goToPreviousPage : null,
        ),
        ...List.generate(
          (endPage - startPage + 1),
          (index) {
            int pageNumber = startPage + index;
            return GestureDetector(
              onTap: () {
                if (pageNumber != currentPage) {
                  loadTransfers(page: pageNumber);
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: pageNumber == currentPage
                      ? Colors.white
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2.0,
                  ),
                ),
                child: Text(
                  '$pageNumber',
                  style: TextStyle(
                    color:
                        pageNumber == currentPage ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
          onPressed: hasNextPage ? goToNextPage : null,
        ),
      ],
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

  Widget buildBarChart() {
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
        periods.add("${DateFormat('d MMM').format(startOfWeek)}");
        date = date.subtract(const Duration(days: 7));
      } else if (selectedPeriod == 'Day') {
        periods.add(DateFormat('d MMM').format(date));
        date = date.subtract(const Duration(days: 1));
      }
    }

    periods = periods.reversed.toList();

    List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < periods.length; i++) {
      double income = 0, expenses = 0, difference = 0;

      final periodTransfers = chartTransfers.where((transfer) {
        final transferDate = transfer['transfer_date'];
        String periodLabel;

        if (selectedPeriod == 'Year') {
          periodLabel = DateFormat('yyyy').format(transferDate);
        } else if (selectedPeriod == 'Month') {
          periodLabel = DateFormat('MMM yyyy').format(transferDate);
        } else if (selectedPeriod == 'Week') {
          DateTime startOfWeek =
              transferDate.subtract(Duration(days: transferDate.weekday - 1));
          periodLabel = DateFormat('d MMM').format(startOfWeek);
        } else {
          periodLabel = DateFormat('d MMM').format(transferDate);
        }
        return periodLabel == periods[i];
      }).toList();

      for (var transfer in periodTransfers) {
        final amount = double.parse(transfer['amount'].toString());
        if (transfer['type'] == 'Income') {
          income += amount;
        } else if (transfer['type'] == 'Expenses') {
          expenses += amount;
        }
      }

      difference = income - expenses;

      List<BarChartRodData> rods = [];
      double barWidth = 12;

      if (isGeneral) {
        rods.add(
            BarChartRodData(toY: income, color: Colors.green, width: barWidth));
        rods.add(
            BarChartRodData(toY: expenses, color: Colors.red, width: barWidth));
        rods.add(BarChartRodData(
            toY: difference,
            color: difference >= 0 ? Colors.blue : Colors.orange,
            width: barWidth));
      } else if (isExpenses) {
        rods.add(
            BarChartRodData(toY: expenses, color: Colors.red, width: barWidth));
      } else {
        rods.add(
            BarChartRodData(toY: income, color: Colors.green, width: barWidth));
      }

      barGroups.add(BarChartGroupData(x: i, barRods: rods, barsSpace: 6));
    }

    double maxY = barGroups.isNotEmpty
        ? barGroups
            .expand((group) => group.barRods.map((rod) => rod.toY))
            .reduce((a, b) => a > b ? a : b)
        : 1;

    maxY = maxY > 0 ? maxY + (maxY * 0.2) : 1;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barGroups: barGroups,
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withOpacity(0.3),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < periods.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      periods[value.toInt()],
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final label = rodIndex == 0
                  ? 'Income'
                  : rodIndex == 1
                      ? 'Expenses'
                      : 'Net';
              return BarTooltipItem(
                '$label: ${rod.toY.toStringAsFixed(2)}',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
      ),
    );
  }
}
