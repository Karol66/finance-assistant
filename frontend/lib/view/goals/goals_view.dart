import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/view/goals/goals_create_view.dart';

class GoalsView extends StatefulWidget {
  const GoalsView({super.key});

  @override
  _GoalsViewState createState() => _GoalsViewState();
}

class _GoalsViewState extends State<GoalsView> {
  List<Map<String, dynamic>> goals = [
    {
      "icon": Icons.directions_car,
      "label": "Auto & Transport",
      "amountSpent": 25.99,
      "budget": 400.00,
      "remaining": 250.01,
      "progressColor": Colors.green,
    },
    {
      "icon": Icons.movie,
      "label": "Entertainment",
      "amountSpent": 50.99,
      "budget": 600.00,
      "remaining": 300.01,
      "progressColor": Colors.red,
    },
    {
      "icon": Icons.security,
      "label": "Security",
      "amountSpent": 5.99,
      "budget": 600.00,
      "remaining": 250.00,
      "progressColor": Colors.purple,
    },
  ];

  void createGoalClick() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GoalsCreateView(),
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

                  Container(
                    width: 300,
                    height: 300,
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
                              sectionsSpace: 12,
                              centerSpaceRadius: 110,
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

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: goals.length + 1, 
                itemBuilder: (context, index) {
                  if (index == goals.length) {
                    return _buildCreateNewGoalButton();
                  }
                  final goal = goals[index];
                  return _buildGoalItem(
                    icon: goal['icon'],
                    label: goal['label'],
                    amountSpent: goal['amountSpent'],
                    budget: goal['budget'],
                    remaining: goal['remaining'],
                    progressColor: goal['progressColor'],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    final goalData = goals.map((goal) {
      return {
        'color': goal['progressColor'],
        'value': goal['amountSpent'],
        'budget': goal['budget'],
      };
    }).toList();

    return goalData.map((goal) {
      final percentage = (goal['value'] as double) / (goal['budget'] as double) * 100;
      return PieChartSectionData(
        color: goal['color'] as Color,
        value: percentage,
        title: '',
        radius: 30,
        titlePositionPercentageOffset: 0.55,
      );
    }).toList();
  }

  Widget _buildCreateNewGoalButton() {
    return GestureDetector(
      onTap: createGoalClick,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF01C38D),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add, size: 32, color: Colors.white),
            SizedBox(width: 10),
            Text(
              "Create New Goal",
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
