import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GoalsView extends StatelessWidget {
  const GoalsView({super.key});

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF132D46),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Górny kontener z wykresem
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
                  // Wykres kołowy wewnątrz ciemnego kontenera
                  Container(
                    width: 300, // Increased width
                    height: 300, // Increased height
                    decoration: BoxDecoration(
                      color: const Color(0xFF191E29),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              sectionsSpace: 12, // Increased space between sections
                              centerSpaceRadius: 110, // Bigger space in the center
                              sections: showingSections(),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                "\$82.90",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "of \$2,000 budget",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Lista celów budżetowych
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _buildGoalItem(
                    icon: Icons.directions_car,
                    label: "Auto & Transport",
                    amountSpent: 25.99,
                    budget: 400.00,
                    remaining: 250.01,
                    progressColor: Colors.green,
                  ),
                  _buildGoalItem(
                    icon: Icons.movie,
                    label: "Entertainment",
                    amountSpent: 50.99,
                    budget: 600.00,
                    remaining: 300.01,
                    progressColor: Colors.red,
                  ),
                  _buildGoalItem(
                    icon: Icons.security,
                    label: "Security",
                    amountSpent: 5.99,
                    budget: 600.00,
                    remaining: 250.00,
                    progressColor: Colors.purple,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Funkcja zwracająca sekcje wykresu
  List<PieChartSectionData> showingSections() {
    // Dane celów budżetowych
    final goalData = [
      {'color': Colors.green, 'value': 25.99, 'budget': 400.00},
      {'color': Colors.red, 'value': 50.99, 'budget': 600.00},
      {'color': Colors.purple, 'value': 5.99, 'budget': 600.00},
    ];

    // Tworzenie sekcji na podstawie danych
    return goalData.map((goal) {
      final percentage = (goal['value'] as double) / (goal['budget'] as double) * 100;
      return PieChartSectionData(
        color: goal['color'] as Color,
        value: percentage,
        title: '',
        radius: 30, // Smaller radius for each section
        titlePositionPercentageOffset: 0.55,
      );
    }).toList();
  }

  // Widget dla pojedynczego celu budżetowego
  Widget _buildGoalItem({
    required IconData icon,
    required String label,
    required double amountSpent,
    required double budget,
    required double remaining,
    required Color progressColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF191E29),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.white, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                "\$$amountSpent",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "\$$remaining left to spend of \$$budget",
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (budget - remaining) / budget,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            backgroundColor: Colors.grey[800],
          ),
        ],
      ),
    );
  }
}
