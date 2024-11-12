import 'package:flutter/material.dart';
import 'package:frontend/services/linear_regression.dart';
import 'package:intl/intl.dart';

class SavingStrategies extends StatefulWidget {
  const SavingStrategies({Key? key}) : super(key: key);

  @override
  _SavingStrategiesState createState() => _SavingStrategiesState();
}

class _SavingStrategiesState extends State<SavingStrategies> {
  final LinearRegressionService _service = LinearRegressionService();
  List<dynamic> strategy = [];

  @override
  void initState() {
    super.initState();
    fetchStrategy();
  }

  Future<void> fetchStrategy() async {
    final fetchedStrategy = await _service.fetchPredictedAndAllocatedSavings();
    setState(() {
      strategy = fetchedStrategy ?? [];
    });
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
      body: ListView.builder(
        itemCount: strategy.length,
        itemBuilder: (context, index) {
          final goal = strategy[index];
          return _buildStrategyItem(goal);
        },
      ),
    );
  }

  Widget _buildStrategyItem(Map<String, dynamic> goal) {
    double goalAmount = goal['target_amount'];
    bool isUnachievable = goal['unachievable'] ?? false;
    double missingAmount = (goal['missing_amount'] ?? 0).toDouble();

    String estimatedDateText = isUnachievable
        ? "Currently Unachievable"
        : "Estimated Achievement Date: ${DateFormat('yyyy-MM-dd').format(DateFormat('yyyy-MM-dd').parse(goal['estimated_end_date']))}";

    List<dynamic> allocations = goal['monthly_allocations'] ?? [];

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
                    goal['goal_name'] ?? "No Goal Name",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                "\$${goalAmount.toStringAsFixed(2)}",
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
            estimatedDateText,
            style: TextStyle(
              color: isUnachievable ? Colors.redAccent : Colors.white54,
              fontSize: 14,
              fontWeight: isUnachievable ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ...allocations.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, dynamic> allocation = entry.value;
                double allocationFraction = (allocation['amount'] / goalAmount * 1000).toInt().toDouble();
                Color allocationColor = _getAllocationColor(allocation['month']);
                
                BorderRadius borderRadius = BorderRadius.zero;
                if (index == 0) {
                  borderRadius = const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  );
                } else if (index == allocations.length - 1 && !isUnachievable) {
                  borderRadius = const BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  );
                }

                return Expanded(
                  flex: allocationFraction.toInt(),
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: allocationColor,
                      borderRadius: borderRadius,
                    ),
                  ),
                );
              }).toList(),
              if (isUnachievable)
                Expanded(
                  flex: ((missingAmount / goalAmount) * 1000).toInt(),
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: allocations.map((allocation) {
              Color allocationColor = _getAllocationColor(allocation['month']);
              return Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: allocationColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text(
                    allocation['month'],
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "\$${allocation['amount'].toStringAsFixed(2)}",
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Color _getAllocationColor(String month) {
    final colors = [
      Colors.greenAccent,
      Colors.lightBlueAccent,
      Colors.orangeAccent,
      Colors.purpleAccent,
      Colors.pinkAccent,
      Colors.yellowAccent,
    ];
    int monthIndex = DateFormat('yyyy-MM').parse(month).month % colors.length;
    return colors[monthIndex];
  }
}
