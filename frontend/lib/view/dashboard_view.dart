import 'package:flutter/material.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  bool isExpanses = true;

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
      "price": "1500.00",
    },
    {
      "name": "Freelance",
      "category_color": Colors.blue,
      "icon": Icons.work,
      "price": "250.00",
    },
  ];

  // Funkcja zwraca listę transakcji w zależności od aktywnej kategorii
  List<Map<String, dynamic>> getCurrentList() {
    return isExpanses ? expensesList : incomeList;
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Szary element na górze
            Container(
              height: media.width * 1.1, // Pozostawiamy bez zmian
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(25),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Przełączniki Expenses i Income w formie linków jak we Flet (pełna szerokość)
            Row(
              children: [
                // Przełącznik Expenses
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isExpanses = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10), // Zostawiamy rozmiar
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isExpanses ? Colors.white : Colors.transparent,
                            width: 2.0,
                          ),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Expenses",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18, // Zostawiamy rozmiar czcionki
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                // Przełącznik Income
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isExpanses = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10), // Zostawiamy rozmiar
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: !isExpanses ? Colors.white : Colors.transparent,
                            width: 2.0,
                          ),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Income",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18, // Zostawiamy rozmiar czcionki
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

                return GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${transaction["name"]} tapped!')),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(14), // Zwiększony padding (pośredni)
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(12), // Pośrednie zaokrąglenie
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            // Ikona kategorii
                            Container(
                              width: 35, // Pośredni rozmiar ikony
                              height: 35, // Pośredni rozmiar ikony
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: transaction['category_color'],
                              ),
                              child: Center(
                                child: Icon(
                                  transaction['icon'],
                                  color: Colors.white,
                                  size: 18, // Pośredni rozmiar ikony
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Nazwa kategorii
                            Text(
                              transaction["name"],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15, // Pośredni rozmiar tekstu
                              ),
                            ),
                          ],
                        ),
                        // Cena transakcji
                        Text(
                          "\$${transaction["price"]}",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15, // Pośredni rozmiar tekstu
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
