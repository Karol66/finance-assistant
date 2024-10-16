import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  bool isGeneral = true;
  bool isExpanses = false;
  String selectedPeriod = 'Year';

  // Przykładowe dane dla transakcji
  List<Map<String, dynamic>> expensesList = [
    {
      "name": "Spotify",
      "category_color": Colors.green,
      "icon": Icons.music_note,
      "price": "5.99",
    },
    {
      "name": "Youtube",
      "category_color": Colors.red,
      "icon": Icons.video_collection,
      "price": "18.99",
    },
    {
      "name": "Microsoft",
      "category_color": Colors.blue,
      "icon": Icons.computer,
      "price": "29.99",
    },
    {
      "name": "Netflix",
      "category_color": Colors.orange,
      "icon": Icons.movie,
      "price": "15.00",
    },
  ];

  List<Map<String, dynamic>> incomeList = [
    {
      "name": "Salary",
      "category_color": Colors.purple,
      "icon": Icons.attach_money,
      "price": "150.00",
    },
    {
      "name": "Freelance",
      "category_color": Colors.blue,
      "icon": Icons.work,
      "price": "250.00",
    },
  ];

  List<Map<String, dynamic>> getAllTransactions() {
    return [...expensesList, ...incomeList];
  }

  List<Map<String, dynamic>> getCurrentList() {
    if (isGeneral) {
      return getAllTransactions();
    } else if (isExpanses) {
      return expensesList;
    } else {
      return incomeList;
    }
  }

  bool isExpenseTransaction(Map<String, dynamic> transaction) {
    return expensesList.contains(transaction);
  }

  // Obliczanie sumy wydatków lub dochodów
  double getTotalAmount() {
    double totalIncome = incomeList.fold(0.0, (sum, item) => sum + double.parse(item['price']));
    double totalExpanses = expensesList.fold(0.0, (sum, item) => sum + double.parse(item['price']));
    
    if (isGeneral) {
      double diffrence = totalIncome - totalExpanses;
      return diffrence;
    } else if (isExpanses) {
      return totalExpanses;
    } else {
      return totalIncome;
    }
  }

  // Obliczanie danych dla wykresu kołowego na podstawie wybranej kategorii
  List<PieChartSectionData> getPieChartData() {
    List<Map<String, dynamic>> currentList = getCurrentList();

    return currentList.map((transaction) {
      double value = double.parse(transaction["price"]);
      return PieChartSectionData(
        color: transaction["category_color"],
        value: value,
        title: '',
        radius: 30, // Zmiana szerokości fragmentów wykresu na 30
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
            // Szary element na górze z wykresem kołowym
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
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedPeriod = 'Year';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: selectedPeriod == 'Year'
                                        ? Colors.white
                                        : Colors.transparent,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "Year",
                                style: TextStyle(
                                  color: selectedPeriod == 'Year'
                                      ? Colors.white
                                      : Colors.grey,
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
                                selectedPeriod = 'Month';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: selectedPeriod == 'Month'
                                        ? Colors.white
                                        : Colors.transparent,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "Month",
                                style: TextStyle(
                                  color: selectedPeriod == 'Month'
                                      ? Colors.white
                                      : Colors.grey,
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
                                selectedPeriod = 'Week';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: selectedPeriod == 'Week'
                                        ? Colors.white
                                        : Colors.transparent,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "Week",
                                style: TextStyle(
                                  color: selectedPeriod == 'Week'
                                      ? Colors.white
                                      : Colors.grey,
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
                                selectedPeriod = 'Day';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: selectedPeriod == 'Day'
                                        ? Colors.white
                                        : Colors.transparent,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "Day",
                                style: TextStyle(
                                  color: selectedPeriod == 'Day'
                                      ? Colors.white
                                      : Colors.grey,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10), // Odstęp przed wykresem
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              sectionsSpace: 12, // Odstęp między sekcjami
                              centerSpaceRadius: 110,
                              sections: getPieChartData(),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${isExpanses ? '-' : '+'} \$${getTotalAmount().toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: isExpanses ? Colors.red : Colors.green,
                                ),
                              ),
                              Text(
                                isExpanses ? "Total Expenses" : "Total Income",
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
                        isExpanses = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isGeneral && !isExpanses
                                ? Colors.white
                                : Colors.transparent,
                            width: 2.0,
                          ),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "General",
                        style: TextStyle(
                          color: isGeneral && !isExpanses
                              ? Colors.white
                              : Colors.grey,
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
                        isExpanses = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: !isGeneral && isExpanses
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
                          color: !isGeneral && isExpanses
                              ? Colors.white
                              : Colors.grey,
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
                        isExpanses = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: !isGeneral && !isExpanses
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
                          color: !isGeneral && !isExpanses
                              ? Colors.white
                              : Colors.grey,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Lista transakcji
            ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: getCurrentList().length,
              itemBuilder: (context, index) {
                var transaction = getCurrentList()[index];
                bool isExpense = isExpenseTransaction(transaction);

                return GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${transaction["name"]} tapped!')),
                    );
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
                            // Ikona kategorii
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: transaction['category_color'],
                              ),
                              child: Center(
                                child: Icon(
                                  transaction['icon'],
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            // Nazwa kategorii
                            Text(
                              transaction["name"],
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        // Cena transakcji z plusem lub minusem i odpowiednim kolorem
                        Text(
                          "${isExpense ? '-' : '+'} \$${transaction["price"]}",
                          style: TextStyle(
                            color: isExpense ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
