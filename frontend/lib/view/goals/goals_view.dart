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
  bool isActive = true;
  List<Map<String, dynamic>> goals = [];
  final GoalsService _goalsService = GoalsService();
  int currentPage = 1;
  bool hasNextPage = true;

  @override
  void initState() {
    super.initState();
    _initializeGoals();
  }

  void _initializeGoals() {
    final status = isActive ? "active" : "completed";
    loadGoals(status: status, page: 1);
  }

  Future<void> loadGoals({required String status, int page = 1}) async {
    final fetchedGoals =
        await _goalsService.fetchGoals(page: page, status: status);
    if (fetchedGoals != null) {
      setState(() {
        goals = (fetchedGoals['results'] as List)
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
        currentPage = page;
        hasNextPage = page < fetchedGoals['total_pages'];
      });
    } else {
      print("Failed to load goals.");
    }
  }

  void goToNextPage() {
    if (hasNextPage) {
      loadGoals(
          status: isActive ? "active" : "completed", page: currentPage + 1);
    }
  }

  void goToPreviousPage() {
    if (currentPage > 1) {
      loadGoals(
          status: isActive ? "active" : "completed", page: currentPage - 1);
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
        loadGoals(status: isActive ? "active" : "completed", page: 1);
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
        loadGoals(status: isActive ? "active" : "completed", page: 1);
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
        loadGoals(status: isActive ? "active" : "completed", page: 1);
      }
    });
  }

  void onLinkClick(bool showActive) {
    setState(() {
      isActive = showActive;
      loadGoals(status: isActive ? "active" : "completed", page: 1);
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
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      onLinkClick(true);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isActive ? Colors.white : Colors.transparent,
                            width: 2.0,
                          ),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Active",
                        style: TextStyle(
                          color: isActive ? Colors.white : Colors.grey[600],
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
                      onLinkClick(false);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color:
                                !isActive ? Colors.white : Colors.transparent,
                            width: 2.0,
                          ),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Completed",
                        style: TextStyle(
                          color: !isActive ? Colors.white : Colors.grey[600],
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
                  return goalItem(goal);
                },
              ),
            ),
            const SizedBox(height: 10),
            _buildPaginationControls(),
          ],
        ),
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
                  loadGoals(status: isActive ? "active" : "completed", page: 1);
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

  Widget goalItem(Map<String, dynamic> goal) {
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
          loadGoals(status: isActive ? "active" : "completed", page: 1);
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
