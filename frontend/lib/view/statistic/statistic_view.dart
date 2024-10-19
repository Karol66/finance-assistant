import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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
  DateTime selectedDate = DateTime.now();  // Przechowuje wybraną datę

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
      "price": "50.00",
    },
    {
      "name": "Freelance",
      "category_color": Colors.blue,
      "icon": Icons.work,
      "price": "5.00",
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
              height: 415, // zwiększenie wysokości, aby zmieścić tekst i wykres
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
                    const SizedBox(height: 10), // Odstęp między datą a wykresem
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
                                  switch (value.toInt()) {
                                    case 0:
                                      return Text('mon', style: style);
                                    case 1:
                                      return Text('tue', style: style);
                                    case 2:
                                      return Text('wen', style: style);
                                    case 3:
                                      return Text('thu', style: style);
                                    case 4:
                                      return Text('fri', style: style);
                                    default:
                                      return Text('', style: style);
                                  }
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
                          barGroups: isGeneral
                              ? createGeneralBarGroups() // Generuj słupki dla trybu "General"
                              : createBarGroups(), // Dla trybów "Expenses" i "Income"
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
                            Text(
                              transaction["name"],
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
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

  // Generowanie słupków dla trybu "General" (przychody, wydatki, różnica na każdy dzień)
  List<BarChartGroupData> createGeneralBarGroups() {
    List<double> incomes = [
      8.0,
      18.0,
      5.0,
      13.0,
      6.0
    ]; // przykładowe dane przychodów
    List<double> expenses = [
      6.0,
      14.0,
      8.0,
      11.0,
      10.0
    ]; // przykładowe dane wydatków

    return List.generate(5, (index) {
      double difference = incomes[index] - expenses[index];
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: incomes[index],
            color: Colors.green,
            width: 11,
          ),
          BarChartRodData(
            toY: expenses[index],
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
    });
  }

  // Generowanie słupków dla trybu "Expenses" i "Income"
  List<BarChartGroupData> createBarGroups() {
    List<double> sums = calculateTransactionSums();

    return List.generate(5, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: sums[index],
            color: sums[index] >= 0 ? Colors.green : Colors.red,
            width: 11,
          ),
        ],
        barsSpace: 6,
      );
    });
  }

  // Funkcja do obliczania sumy transakcji (w zależności od trybu)
  List<double> calculateTransactionSums() {
    List<double> sums =
        List.filled(5, 0.0); // tablica z sumami dla każdego dnia

    for (var transaction in getCurrentList()) {
      double price = double.parse(transaction['price']);
      // Zakładamy losowy podział transakcji na dni (do zaimplementowania)
      int dayIndex = getDayIndexForTransaction(transaction);
      sums[dayIndex] += isExpenseTransaction(transaction) ? -price : price;
    }

    return sums;
  }

  // Funkcja do przypisywania transakcji do dni
  int getDayIndexForTransaction(Map<String, dynamic> transaction) {
    // Przykładowo, przypisujemy losowo do dni tygodnia
    return DateTime.now().weekday % 5;
  }

  double calculateMaxY() {
    if (isGeneral) {
      List<double> incomes = [8.0, 18.0, 5.0, 13.0, 6.0];
      List<double> expenses = [6.0, 14.0, 8.0, 11.0, 10.0];
      
      // Find the maximum value in both incomes and expenses
      double maxIncome = incomes.reduce((a, b) => a > b ? a : b);
      double maxExpense = expenses.reduce((a, b) => a > b ? a : b);
      
      // Return the highest of the two, with a margin for better visualization
      return (maxIncome > maxExpense ? maxIncome : maxExpense) + 10;
    } else {
      // For other modes (Expenses, Income), use the current logic
      List<double> transactionSums = calculateTransactionSums();
      double maxTransactionValue = transactionSums.reduce((a, b) => a > b ? a : b).abs();
      return maxTransactionValue + 10;
    }
  }
}
