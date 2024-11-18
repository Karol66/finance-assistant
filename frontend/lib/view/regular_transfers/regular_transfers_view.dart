import 'package:flutter/material.dart';
import 'package:frontend/services/transfers_service.dart';
import 'package:frontend/view/regular_transfers/regular_transfers_create_view.dart';
import 'package:frontend/view/regular_transfers/regular_transfers_manage_view.dart';
import 'package:intl/intl.dart';

class RegularTransfersView extends StatefulWidget {
  const RegularTransfersView({super.key});

  @override
  _RegularTransfersViewState createState() => _RegularTransfersViewState();
}

class _RegularTransfersViewState extends State<RegularTransfersView> {
  bool isGeneral = true;
  bool isExpenses = true;

  List<Map<String, dynamic>> regularTransfers = [];

  final TransfersService _transfersService = TransfersService();

  String selectedPeriod = 'Year';
  DateTime selectedDate = DateTime.now();

  int currentPage = 1;
  bool hasNextPage = true;

  @override
  void initState() {
    super.initState();
    loadRegularTransfers(page: 1);
  }

  Future<void> loadRegularTransfers({int page = 1}) async {
    String? type;
    if (isGeneral) {
      type = null;
    } else if (isExpenses) {
      type = 'expense';
    } else {
      type = 'income';
    }

    final fetchedTransfers = await _transfersService.fetchRegularTransfers(
      page: page,
      period: selectedPeriod.toLowerCase(),
      date: selectedDate,
      type: type,
    );
    if (fetchedTransfers != null) {
      setState(() {
        regularTransfers =
            (fetchedTransfers['results'] as List).map((transfer) {
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
      loadRegularTransfers(page: currentPage - 1);
    }
  }

  void goToNextPage() {
    if (hasNextPage) {
      loadRegularTransfers(page: currentPage + 1);
    }
  }

  Color _parseColor(String colorString) {
    return Color(
        int.parse(colorString.substring(1, 7), radix: 16) + 0xFF000000);
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
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
    loadRegularTransfers();
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
    loadRegularTransfers();
  }

  List<Map<String, dynamic>> _filteredTransfers() {
    if (isGeneral) {
      return regularTransfers;
    } else if (isExpenses) {
      return regularTransfers
          .where((transfer) => transfer['type'] == 'Expenses')
          .toList();
    } else {
      return regularTransfers
          .where((transfer) => transfer['type'] == 'Income')
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF132D46),
      appBar: AppBar(
        title: const Text('Regular Transfers'),
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
          Container(
            width: media.width,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
                      icon:
                          const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: goToPreviousPeriod,
                    ),
                    Text(
                      getFormattedPeriod(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios,
                          color: Colors.white),
                      onPressed: goToNextPeriod,
                    ),
                  ],
                ),
              ],
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
                    loadRegularTransfers();
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
                    loadRegularTransfers();
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
                    loadRegularTransfers();
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
                return regularTransferItem(transfer);
              },
            ),
          ),
          const SizedBox(height: 10),
          _buildPaginationControls(),
        ],
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
                  loadRegularTransfers(page: pageNumber);
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
          loadRegularTransfers();
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

  Widget regularTransferItem(Map<String, dynamic> transfer) {
    DateTime transferDate = transfer['transfer_date'];
    double amount = double.tryParse(transfer['amount'].toString()) ?? 0.0;
    bool isExpense = transfer['type'] == 'Expenses';
    String formattedAmount = isExpense
        ? "-\$${amount.abs().toStringAsFixed(2)}"
        : "+\$${amount.toStringAsFixed(2)}";
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RegularTransfersManageView(
              transferId: transfer["id"],
            ),
          ),
        );
        if (result == true) {
          loadRegularTransfers();
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF191E29),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: transfer['category_color'],
                shape: BoxShape.circle,
              ),
              child: Icon(
                IconData(int.parse(transfer['category_icon']),
                    fontFamily: 'MaterialIcons'),
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transfer['description'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(transferDate),
                    style: const TextStyle(
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              formattedAmount,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isExpense ? Colors.red : Colors.green,
              ),
            ),
          ],
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
            builder: (context) => const RegularTransfersCreateView(),
          ),
        );
        if (result == true) {
          loadRegularTransfers();
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
              "Create New Regular Transfer",
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