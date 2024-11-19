import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/services/transfers_service.dart';
import 'package:frontend/view/transfers/transfers_create_view.dart';
import 'package:intl/intl.dart';
import 'package:frontend/view/transfers/transfers_manage_view.dart';

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
  List<Map<String, dynamic>> groupedTransfers = [];

  final TransfersService _transfersService = TransfersService();

  int currentPage = 1;
  bool hasNextPage = true;

  double totalIncome = 0.0;
  double totalExpenses = 0.0;
  double totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    loadTransfers();
    loadGroupedTransfers();
    getTotalAmount();
  }

  Future<void> getTotalAmount() async {
    final result = await _transfersService.fetchProfitLoss(
      period: selectedPeriod.toLowerCase(),
      date: selectedDate,
      type: isGeneral ? null : (isExpenses ? 'expense' : 'income'),
    );

    if (result != null) {
      setState(() {
        totalIncome = result['total_income'];
        totalExpenses = result['total_expense'];

        if (isGeneral) {
          totalAmount = totalIncome - totalExpenses;
        } else if (isExpenses) {
          totalAmount = totalExpenses;
        } else {
          totalAmount = totalIncome;
        }
      });
    } else {
      print('Failed to fetch total amount from backend.');
    }
  }

  Future<void> loadGroupedTransfers() async {
    final fetchedGroupedTransfers =
        await _transfersService.fetchTransfersGroupedByCategory(
      period: selectedPeriod.toLowerCase(),
      date: selectedDate,
      type: isExpenses
          ? 'expense'
          : isGeneral
              ? null
              : 'income',
    );

    if (fetchedGroupedTransfers != null) {
      setState(() {
        groupedTransfers = fetchedGroupedTransfers.map((item) {
          return {
            "category_name": item['category']['name'],
            "category_color": _parseColor(item['category']['color']),
            "amount": item['total_amount'].toString(),
          };
        }).toList();
      });
    } else {
      print("Failed to load grouped transfers.");
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
    loadGroupedTransfers();
    getTotalAmount();
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
    loadGroupedTransfers();
    getTotalAmount();
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
          loadGroupedTransfers();
          getTotalAmount();
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
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color getTotalAmountColor(double totalAmount) {
    if (isExpenses) {
      return Colors.red;
    } else {
      return totalAmount < 0 ? Colors.red : Colors.green;
    }
  }

  String getTotalAmountText(double totalAmount) {
    if (isExpenses) {
      return "- \$${totalAmount.toStringAsFixed(2)}";
    } else if (totalAmount < 0) {
      return "- \$${totalAmount.abs().toStringAsFixed(2)}";
    } else {
      return "+ \$${totalAmount.toStringAsFixed(2)}";
    }
  }

  List<PieChartSectionData> getPieChartData() {
    double total = groupedTransfers.fold(
        0.0, (sum, transfer) => sum + double.parse(transfer["amount"]));

    return groupedTransfers.map((transfer) {
      double value = double.parse(transfer["amount"]);
      double percentage = (value / total) * 100;

      return PieChartSectionData(
        color: transfer["category_color"],
        value: value,
        title: "${percentage.toStringAsFixed(1)}%",
        radius: 30,
        titlePositionPercentageOffset: 0.55,
        titleStyle: const TextStyle(
          color: Colors.white, 
          fontWeight: FontWeight.bold,
          fontSize: 14, 
        ),  
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
                                isGeneral
                                    ? getTotalAmountText(totalAmount)
                                    : (isExpenses
                                        ? getTotalAmountText(totalExpenses)
                                        : getTotalAmountText(totalIncome)),
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: getTotalAmountColor(
                                    isGeneral
                                        ? totalAmount
                                        : (isExpenses
                                            ? totalExpenses
                                            : totalIncome),
                                  ),
                                ),
                              ),
                              Text(
                                isGeneral
                                    ? "Net Balance"
                                    : (isExpenses
                                        ? "Total Expenses"
                                        : "Total Income"),
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
                      loadGroupedTransfers();
                      getTotalAmount();
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
                      loadGroupedTransfers();
                      getTotalAmount();
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
                      loadGroupedTransfers();
                      getTotalAmount();
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
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
          loadGroupedTransfers();
          getTotalAmount();
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
          loadGroupedTransfers();
          getTotalAmount();
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
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
