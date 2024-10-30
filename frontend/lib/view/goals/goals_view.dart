import 'package:flutter/material.dart';
import 'package:frontend/view/goals/goals_create_view.dart';
import 'package:frontend/view/goals/goals_manage_view.dart';
import 'package:frontend/services/goals_service.dart';
import 'package:frontend/view/linear_regression/predicted_savings_view.dart';
import 'package:frontend/view/linear_regression/saving_strategies.dart';

class GoalsView extends StatefulWidget {
  const GoalsView({super.key});

  @override
  _GoalsViewState createState() => _GoalsViewState();
}

class _GoalsViewState extends State<GoalsView> {
  List<Map<String, dynamic>> goals = [];
  final GoalsService _goalsService = GoalsService();

  @override
  void initState() {
    super.initState();
    loadGoals();
  }

  Future<void> loadGoals() async {
    final fetchedGoals = await _goalsService.fetchGoals();
    if (fetchedGoals != null) {
      setState(() {
        goals = fetchedGoals
            .map((goal) => {
                  "goal_id": goal['id'],
                  "icon": _getIconFromString(goal["goal_icon"]),
                  "goal_name": goal["goal_name"],
                  "current_amount": goal["current_amount"],
                  "target_amount": goal["target_amount"],
                  "remaining": double.parse(goal["target_amount"]) -
                      double.parse(goal["current_amount"]),
                  "goal_color": _parseColor(goal["goal_color"]),
                })
            .toList();
      });
    } else {
      print("Failed to load goals.");
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

  void showPredictedSavings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PredictedSavingsView(),
      ),
    ).then((value) {
      if (value == true) {
        loadGoals();
      }
    });
  }

  void showSavingStrategies() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SavingStrategies(),
      ),
    ).then((value) {
      if (value == true) {
        loadGoals();
      }
    });
  }

  void createGoalClick() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GoalsCreateView(),
      ),
    ).then((value) {
      if (value == true) {
        loadGoals();
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
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: [
                      _buildButton(
                        icon: Icons.show_chart,
                        label: "Predicted Savings",
                        onTap: showPredictedSavings,
                      ),
                      _buildButton(
                        icon: Icons.lightbulb,
                        label: "Saving Strategies",
                        onTap: showSavingStrategies,
                      ),
                    ],
                  ),
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
                  return _buildGoalItem(goal);
                },
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
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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

  Widget _buildGoalItem(Map<String, dynamic> goal) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GoalsManageView(
              goalId: goal["goal_id"],
            ),
          ),
        );
        if (result == true) {
          loadGoals();
        }
      },
      child: Container(
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
                    Icon(goal['icon'], color: Colors.white, size: 24),
                    const SizedBox(width: 10),
                    Text(
                      goal['goal_name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  "\$${goal['current_amount']}",
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
              "\$${goal['remaining']} left to spend of \$${goal['target_amount']}",
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (double.parse(goal['target_amount'].toString()) -
                      double.parse(goal['remaining'].toString())) /
                  double.parse(goal['target_amount'].toString()),
              valueColor: AlwaysStoppedAnimation<Color>(goal['goal_color']),
              backgroundColor: Colors.grey[800],
            ),
          ],
        ),
      ),
    );
  }
}
