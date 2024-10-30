import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/services/linear_regression.dart';

class PredictedSavingsView extends StatefulWidget {
  const PredictedSavingsView({super.key});

  @override
  _PredictedSavingsViewState createState() => _PredictedSavingsViewState();
}

class _PredictedSavingsViewState extends State<PredictedSavingsView> {
  List<double> predictedSavings = [];

  @override
  void initState() {
    super.initState();
    loadPredictedSavings();
  }

  Future<void> loadPredictedSavings() async {
    final service = LinearRegressionService();
    final savings = await service.fetchPredictedSavings();

    if (savings != null) {
      setState(() {
        predictedSavings = savings;
      });
    } else {
      print('Failed to load predicted savings');
    }
  }

  List<BarChartGroupData> createBarGroups() {
    return List.generate(predictedSavings.length, (index) {
      double value = predictedSavings[index];
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: double.parse(value.toStringAsFixed(2)), 
            color: value < 0
                ? Colors.red
                : Colors.green, 
            width: 11,
          ),
        ],
        barsSpace: 6,
      );
    });
  }

  double calculateMaxY() {
    double maxY = predictedSavings.reduce((a, b) => a > b ? a : b);
    return maxY > 0 ? maxY + 10 : 10;
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF132D46),
      appBar: AppBar(
        title: const Text('Predicted Savings'),
        backgroundColor: const Color(0xFF0B6B3A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
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
                  const Text(
                    "Savings Forecast for Next 12 Months",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  if (predictedSavings.isNotEmpty)
                    SizedBox(
                      height: 250,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: calculateMaxY(),
                          barTouchData: BarTouchData(enabled: true),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  showTitles: false), 
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, _) {
                                  return Text(
                                    'M${(value + 1).toInt()}',
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  );
                                },
                                reservedSize: 25,
                              ),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: false,
                          ),
                          barGroups: createBarGroups(),
                        ),
                      ),
                    )
                  else
                    const CircularProgressIndicator(),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  if (predictedSavings.isNotEmpty)
                    ...List.generate(predictedSavings.length, (index) {
                      return _buildSavingsItem(index, predictedSavings[index]);
                    })
                  else
                    const CircularProgressIndicator(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsItem(int monthIndex, double savings) {
    bool isNegative = savings < 0;
    String savingsText = isNegative
        ? "- \$${savings.abs().toStringAsFixed(2)}"
        : "+ \$${savings.toStringAsFixed(2)}";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF191E29),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Month ${monthIndex + 1}",
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 16,
            ),
          ),
          Text(
            savingsText,
            style: TextStyle(
              color: isNegative ? Colors.red : Colors.green,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
