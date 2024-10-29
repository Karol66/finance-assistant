import 'package:flutter/material.dart';
import 'package:frontend/services/linear_regression.dart';

class SavingStrategies extends StatefulWidget {
  const SavingStrategies({Key? key}) : super(key: key);

  @override
  _SavingStrategiesState createState() => _SavingStrategiesState();
}

class _SavingStrategiesState extends State<SavingStrategies> {
  final LinearRegressionService _service = LinearRegressionService();
  List<dynamic> strategy = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStrategy();
  }

  Future<void> fetchStrategy() async {
    final fetchedStrategy = await _service.fetchSavingStrategy();

    if (fetchedStrategy != null) {
      setState(() {
        strategy = fetchedStrategy;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print("Failed to load strategy.");
    }
  }

  IconData _getIconFromString(String iconString) {
    int codePoint = int.tryParse(iconString) ?? 0;
    return IconData(codePoint, fontFamily: 'MaterialIcons');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF132D46),
      appBar: AppBar(
        title: const Text("Proposed Saving Strategy"),
        backgroundColor: const Color(0xFF0B6B3A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: strategy.length,
              itemBuilder: (context, index) {
                final goal = strategy[index];
                return _buildStrategyItem(goal);
              },
            ),
    );
  }

  Widget _buildStrategyItem(Map<String, dynamic> goal) {
    List<double> allocations = goal['monthly_allocation']
        .map<double>((amount) => double.parse(amount.toStringAsFixed(2)))
        .toList();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
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
                  Icon(
                    _getIconFromString(goal['goal_icon'] ?? "0xE853"),
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    goal['goal'] ?? "No Goal Name",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                "\$${goal['target_amount'] ?? 0.0}",
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
            "Estimated Achievement Date: ${goal['estimated_achievement_date'] ?? 'Unknown'}",
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: allocations
                .map((allocation) => Text(
                      "Monthly Allocation: \$${allocation.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Row(
                children: allocations.asMap().entries.map((entry) {
                  int idx = entry.key;
                  double allocation = entry.value;
                  double widthFraction =
                      allocation / (goal['target_amount'] ?? 1);

                  // Wybierz bardziej kontrastowe kolory dla każdego fragmentu
                  Color color = [
                    Colors.blueAccent,
                    Colors.orangeAccent,
                    Colors.greenAccent,
                    Colors.redAccent,
                    Colors.purpleAccent,
                  ][idx % 5]; // Wybór koloru na podstawie indeksu

                  return Expanded(
                    flex: (widthFraction * 1000).toInt(),
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(idx == 0 ? 10 : 0),
                          right: Radius.circular(
                              idx == allocations.length - 1 ? 10 : 0),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
