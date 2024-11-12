import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:frontend/services/linear_regression.dart';

class PredictedSavingsView extends StatefulWidget {
  const PredictedSavingsView({super.key});

  @override
  _PredictedSavingsViewState createState() => _PredictedSavingsViewState();
}

class _PredictedSavingsViewState extends State<PredictedSavingsView> {
  List<Map<String, dynamic>> predictedData = [];
  String selectedPredictionType = 'net_savings';

  @override
  void initState() {
    super.initState();
    loadPredictedData();
  }

  Future<void> loadPredictedData() async {
    final service = LinearRegressionService();
    List<Map<String, dynamic>>? data;

    if (selectedPredictionType == 'expenses') {
      data = await service.fetchPredictedExpenses();
    } else if (selectedPredictionType == 'income') {
      data = await service.fetchPredictedIncome();
    } else if (selectedPredictionType == 'net_savings') {
      data = await service.fetchPredictedNetSavings();
    }

    setState(() {
      predictedData = data ?? [];
    });
  }

  List<BarChartGroupData> createBarGroups() {
    return List.generate(predictedData.length, (index) {
      double value = 0;
      if (selectedPredictionType == 'net_savings') {
        value = predictedData[index]['Prognozowany bilans (przychody - wydatki)'] ?? 0;
      } else {
        value = predictedData[index]['Predicted Amount'] ?? 0;
      }
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: double.parse(value.toStringAsFixed(2)),
            color: value < 0 ? Colors.red : Colors.green,
            width: 11,
          ),
        ],
        barsSpace: 6,
      );
    });
  }

  double calculateMaxY() {
    if (predictedData.isEmpty) return 10;

    double maxY = predictedData
        .map((item) {
          if (selectedPredictionType == 'net_savings') {
            return (item['Prognozowany bilans (przychody - wydatki)'] ?? 0).toDouble();
          } else {
            return (item['Predicted Amount'] ?? 0).toDouble();
          }
        })
        .reduce((a, b) => a > b ? a : b);

    return maxY > 0 ? maxY + 10 : 10;
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF132D46),
      appBar: AppBar(
        title: const Text('Predicted Data'),
        backgroundColor: const Color(0xFF0B6B3A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
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
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 16),
                    child: Column(
                      children: [
                        Text(
                          "Forecast for Next 6 Months",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                        ),
                        const SizedBox(height: 20),
                        if (predictedData.isNotEmpty)
                          SizedBox(
                            height: 250,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: calculateMaxY(),
                                barTouchData: BarTouchData(enabled: true),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, _) {
                                        final date = DateTime.parse(predictedData[value.toInt()]['Data operacji']);
                                        final formattedDate = DateFormat('MMM yyyy').format(date);
                                        return Text(
                                          formattedDate,
                                          style: const TextStyle(
                                            color: Colors.white54,
                                            fontSize: 11, 
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
                                borderData: FlBorderData(show: false),
                                barGroups: createBarGroups(),
                              ),
                            ),
                          )
                        else
                          const Text(
                            "No data available.",
                            style:
                                TextStyle(color: Colors.white54, fontSize: 16),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildTypeSelector("Net Savings", 'net_savings'),
                      _buildTypeSelector("Expenses", 'expenses'),
                      _buildTypeSelector("Income", 'income'),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        if (predictedData.isNotEmpty)
                          ...List.generate(predictedData.length, (index) {
                            return predictionItem(
                                index, predictedData[index]);
                          })
                        else
                          const Text(
                            "No data available.",
                            style:
                                TextStyle(color: Colors.white54, fontSize: 16),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector(String title, String type) {
    bool isSelected = selectedPredictionType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedPredictionType = type;
          });
          loadPredictedData();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 2.0,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget predictionItem(int monthIndex, Map<String, dynamic> data) {
    double amount = 0;
    if (selectedPredictionType == 'net_savings') {
      amount = data['Prognozowany bilans (przychody - wydatki)'] ?? 0;
    } else {
      amount = data['Predicted Amount'] ?? 0;
    }

    bool isNegative = amount < 0;
    String amountText = isNegative
        ? "- \$${amount.abs().toStringAsFixed(2)}"
        : "+ \$${amount.toStringAsFixed(2)}";

    final date = DateTime.parse(data['Data operacji']); 
    final formattedDate = DateFormat('MMMM yyyy').format(date); 

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
            formattedDate,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 16,
            ),
          ),
          Text(
            amountText,
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
