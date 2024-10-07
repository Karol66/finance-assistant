import 'package:flutter/material.dart';
import 'package:frontend/view/accounts/accounts_create_view.dart';

class AccountView extends StatefulWidget {
  const AccountView({Key? key}) : super(key: key);

  @override
  _AccountViewState createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  List<Map<String, dynamic>> accounts = [
    {
      "account_id": 1,
      "account_name": "Savings",
      "balance": "1200.50",
      "account_color": Colors.blue,
      "account_icon": Icons.savings,
      "include_in_total": 1,
    },
    {
      "account_id": 2,
      "account_name": "Checking",
      "balance": "-50.00",
      "account_color": Colors.green,
      "account_icon": Icons.account_balance_wallet,
      "include_in_total": 1,
    },
    {
      "account_id": 3,
      "account_name": "Credit Card",
      "balance": "-500.00",
      "account_color": Colors.red,
      "account_icon": Icons.credit_card,
      "include_in_total": 1,
    },
    {
      "account_id": 4,
      "account_name": "Investment",
      "balance": "2500.00",
      "account_color": Colors.purple,
      "account_icon": Icons.trending_up,
      "include_in_total": 1,
    },
  ];

  double totalBalance = 0.00;

  @override
  void initState() {
    super.initState();
    _updateTotalBalance();
  }

  void _updateTotalBalance() {
    totalBalance = accounts.fold(
      0.0,
      (sum, account) =>
          sum +
          (account["include_in_total"] == 1
              ? double.parse(account["balance"])
              : 0.0),
    );
  }

  void createAccountClick() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AccountsCreateView(),
      ),
    );
  }

    void transferHistoryClick() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AccountsCreateView(),
      ),
    );
  }

    void newTransferClick() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AccountsCreateView(),
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
            // Główny kontener obejmujący Total Balance i przyciski
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
                  // Sekcja Total Balance
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
                  // Grid z przyciskami
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
                    itemCount: accounts.length + 1, // Zwiększ itemCount o 1
                    itemBuilder: (context, index) {
                      if (index == accounts.length) {
                        // Ostatni element - przycisk "Create New Account"
                        return _buildCreateNewAccountButton();
                      }
                      final account = accounts[index];
                      return _buildAccountItem(account);
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

  Widget _buildCreateNewAccountButton() {
    return GestureDetector(
      onTap: createAccountClick,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF01C38D),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, size: 32, color: Colors.white),
            const SizedBox(width: 10),
            const Text(
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

  // Widget dla przycisku
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

  // Widget dla wyświetlania konta
  Widget _buildAccountItem(Map<String, dynamic> account) {
    double balance = double.parse(account['balance']);
    bool isNegative = balance < 0;
    String balanceText = isNegative
        ? "- \$${balance.abs().toStringAsFixed(2)}"
        : "+ \$${balance.toStringAsFixed(2)}";

    return GestureDetector(
      onTap: () {
        print("Manage account: ${account['account_name']}");
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(
              0xFF191E29), // Zmieniony kolor na ten sam co ciemny kontener
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
}
