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
      // Optionally, handle error in UI
      print("Failed to load strategy.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Proposed Saving Strategy")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: strategy.length,
              itemBuilder: (context, index) {
                final goal = strategy[index];
                return Card(
                  child: ListTile(
                    title: Text(goal['goal']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Target Amount: ${goal['target_amount']}"),
                        Text("Estimated Achievement Date: ${goal['estimated_achievement_date']}"),
                        Text("Monthly Allocation: ${goal['monthly_allocation'].join(', ')}"),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
