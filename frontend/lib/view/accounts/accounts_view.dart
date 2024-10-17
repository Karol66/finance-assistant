import 'package:flutter/material.dart';
import 'package:frontend/services/accounts_service.dart';
import 'package:frontend/view/accounts/accounts_create_view.dart';
import 'package:frontend/view/accounts/accounts_manage_view.dart';
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

  @override
  void initState() {
    super.initState();
    loadAccounts();
  }

  Future<void> loadAccounts() async {
    final fetchedAccounts = await _accountsService.fetchAccounts();

    if (fetchedAccounts != null) {
      setState(() {
        accounts = fetchedAccounts
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
        _updateTotalBalance();
      });
    } else {
      print("Failed to load accounts.");
    }
  }

  void _updateTotalBalance() {
    totalBalance = accounts.fold(
      0.0,
      (sum, account) =>
          sum +
          ((account["include_in_total"] == true)
              ? double.parse(account["balance"].toString())
              : 0.0),
    );
  }

  IconData _getIconFromString(String iconString) {
    int codePoint = int.tryParse(iconString) ?? 0;
    return IconData(codePoint, fontFamily: 'MaterialIcons');
  }

  Color _parseColor(String colorString) {
    return Color(
        int.parse(colorString.substring(1, 7), radix: 16) + 0xFF000000);
  }

  void transferHistoryClick() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TransfersView(),
      ),
    );
  }

  void newTransferClick() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TransfersCreateView(),
      ),
    );
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
              decoration: const BoxDecoration(
                color: Color(0xFF191E29),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                children: [
                  Column(
                    children: [
                      const Text(
                        "Total Balance:",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      Text(
                        "\$$totalBalance",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: [
                      _buildButton(
                        icon: Icons.history,
                        label: "Transfer history",
                        onTap: transferHistoryClick,
                      ),
                      _buildButton(
                        icon: Icons.sync,
                        label: "New transfer",
                        onTap: newTransferClick,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: accounts.length + 1,
                    itemBuilder: (context, index) {
                      if (index == accounts.length) {
                        return createAddButton();
                      }
                      final account = accounts[index];
                      return accountItem(account);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
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
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
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
          loadAccounts();
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
          loadAccounts();
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
