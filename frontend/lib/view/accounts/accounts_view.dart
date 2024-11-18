import 'package:flutter/material.dart';
import 'package:frontend/services/accounts_service.dart';
import 'package:frontend/view/accounts/accounts_create_view.dart';
import 'package:frontend/view/accounts/accounts_manage_view.dart';
import 'package:frontend/view/regular_transfers/regular_transfers_view.dart';
import 'package:frontend/view/transfers/transfers_create_view.dart';
import 'package:frontend/view/transfers/transfers_view.dart';

class AccountView extends StatefulWidget {
  const AccountView({super.key});

  @override
  _AccountViewState createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  List<Map<String, dynamic>> accounts = [];
  final AccountsService _accountsService = AccountsService();
  double totalBalance = 0.00;
  int currentPage = 1;
  bool hasNextPage = true;

  @override
  void initState() {
    super.initState();
    loadAccounts(page: 1);
    loadTotalBalance();
  }

  Future<void> loadTotalBalance() async {
    final fetchedBalance = await _accountsService.fetchTotalAccountBalance();
    if (fetchedBalance != null) {
      setState(() {
        totalBalance = fetchedBalance;
      });
    } else {
      print("Failed to fetch total balance.");
    }
  }

  Future<void> loadAccounts({int page = 1}) async {
    final fetchedAccounts = await _accountsService.fetchAccounts(page: page);

    if (fetchedAccounts != null) {
      setState(() {
        accounts = (fetchedAccounts['results'] as List)
            .map((account) => {
                  "account_id": account["id"],
                  "account_name": account["account_name"],
                  "account_type": account["account_type"],
                  "balance": account["balance"],
                  "include_in_total": account["include_in_total"],
                  "account_color": _parseColor(account["account_color"]),
                  "account_icon": _getIconFromString(account["account_icon"]),
                })
            .toList();
        currentPage = page;
        hasNextPage = page < fetchedAccounts['total_pages'];
      });
    } else {
      print("Failed to load accounts.");
    }
  }

  void goToNextPage() {
    if (hasNextPage) {
      loadAccounts(page: currentPage + 1);
    }
  }

  void goToPreviousPage() {
    if (currentPage > 1) {
      loadAccounts(page: currentPage - 1);
    }
  }

  Color _getBalanceColor() {
    return totalBalance < 0 ? Colors.red : Colors.green;
  }

  String _getBalanceText() {
    if (totalBalance < 0) {
      return "- \$${totalBalance.abs().toStringAsFixed(2)}";
    } else {
      return "+ \$${totalBalance.toStringAsFixed(2)}";
    }
  }

  IconData _getIconFromString(String iconString) {
    int codePoint = int.tryParse(iconString) ?? 0;
    return IconData(codePoint, fontFamily: 'MaterialIcons');
  }

  Color _parseColor(String colorString) {
    return Color(
        int.parse(colorString.substring(1, 7), radix: 16) + 0xFF000000);
  }

  void transferHistoryClick() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TransfersView(),
      ),
    );
    if (result == true) {
      loadAccounts(page: 1);
      loadTotalBalance();
    }
  }

  void newTransferClick() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TransfersCreateView(),
      ),
    );
    if (result == true) {
      loadAccounts(page: 1);
      loadTotalBalance();
    }
  }

  void regularTransferClick() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RegularTransfersView(),
      ),
    );
    if (result == true) {
      loadAccounts(page: 1);
      loadTotalBalance();
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF132D46),
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
              children: [
                Column(
                  children: [
                    const Text(
                      "Total Balance:",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    Text(
                      _getBalanceText(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _getBalanceColor(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    _buildButton(
                      icon: Icons.history,
                      label: "Transfer History",
                      onTap: transferHistoryClick,
                    ),
                    _buildButton(
                      icon: Icons.sync,
                      label: "New Transfer",
                      onTap: newTransferClick,
                    ),
                    _buildButton(
                      icon: Icons.repeat,
                      label: "Regular Transfers",
                      onTap: regularTransferClick,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: accounts.length + 1,
              itemBuilder: (context, index) {
                if (index == accounts.length) {
                  return createAddButton();
                }
                final account = accounts[index];
                return accountItem(account);
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
                  loadAccounts(page: pageNumber);
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

  Widget _buildButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF191E29),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF1EB980),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              label.replaceAll(" ", "\n"),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget accountItem(Map<String, dynamic> account) {
    double balance = double.parse(account['balance']);
    bool isNegative = balance < 0;
    String balanceText = isNegative
        ? "- \$${balance.abs().toStringAsFixed(2)}"
        : "+ \$${balance.toStringAsFixed(2)}";

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AccountsManageView(
              accountId: account["account_id"],
            ),
          ),
        );
        if (result == true) {
          loadAccounts(page: 1);
          loadTotalBalance();
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: account['account_color'],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(account['account_icon'],
                      size: 20, color: Colors.white),
                ),
                const SizedBox(width: 20),
                Text(
                  account['account_name'],
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
            Text(
              balanceText,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isNegative ? Colors.red : Colors.green,
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
            builder: (context) => const AccountsCreateView(),
          ),
        );
        if (result == true) {
          loadAccounts(page: 1);
          loadTotalBalance();
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
              "Create New Account",
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
