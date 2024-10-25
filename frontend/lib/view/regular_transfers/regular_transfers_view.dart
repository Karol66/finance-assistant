import 'package:flutter/material.dart';
import 'package:frontend/view/regular_transfers/regular_transfers_create_view.dart';

class RegularTransfersView extends StatefulWidget {
  const RegularTransfersView({super.key});

  @override
  _RegularTransfersViewState createState() => _RegularTransfersViewState();
}

class _RegularTransfersViewState extends State<RegularTransfersView> {
  List<Map<String, dynamic>> regularTransfers = [
    {
      "icon": Icons.music_note,
      "description": "Spotify Subscription",
      "amount": 5.99,
      "transfer_date": DateTime(2023, 1, 30),
      "category_color": Colors.green,
    },
    {
      "icon": Icons.video_collection,
      "description": "YouTube Premium",
      "amount": 18.99,
      "transfer_date": DateTime(2023, 1, 30),
      "category_color": Colors.red,
    },
    {
      "icon": Icons.movie,
      "description": "Netflix Subscription",
      "amount": 9.99,
      "transfer_date": DateTime(2023, 2, 2),
      "category_color": Colors.orange,
    },
    {
      "icon": Icons.computer,
      "description": "Microsoft 365",
      "amount": 29.99,
      "transfer_date": DateTime(2023, 2, 5),
      "category_color": Colors.blue,
    },
  ];

  void createRegularTransferClick() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RegularTransfersCreateView(),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Container(
              width: media.width,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF191E29),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: _buildCalendarView(),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: regularTransfers.length + 1,
                itemBuilder: (context, index) {
                  if (index == regularTransfers.length) {
                    return _buildCreateNewRegularTransferButton();
                  }
                  final regularTransfer = regularTransfers[index];
                  return _buildRegularTransferItem(
                    icon: regularTransfer['icon'],
                    description: regularTransfer['description'],
                    amount: regularTransfer['amount'],
                    transferDate: regularTransfer['transfer_date'],
                    categoryColor: regularTransfer['category_color'],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarView() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, 
      child: Row(
        children: List.generate(7, (index) {
          DateTime today = DateTime.now();
          DateTime date = today.add(Duration(days: index));

          return Column(
            children: [
              Text(
                _getWeekday(date),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white54,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 38, 
                height: 38, 
                margin: const EdgeInsets.symmetric(horizontal: 4), 
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: date.day == today.day
                      ? Colors.orange
                      : Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "${date.day}",
                  style: const TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  String _getWeekday(DateTime date) {
    const weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return weekdays[date.weekday - 1];
  }

  Widget _buildCreateNewRegularTransferButton() {
    return GestureDetector(
      onTap: createRegularTransferClick,
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
              "Create Regular Transfer",
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

  Widget _buildRegularTransferItem({
    required IconData icon,
    required String description,
    required double amount,
    required DateTime transferDate,
    required Color categoryColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF191E29),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: categoryColor,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                description,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${transferDate.day}/${transferDate.month}/${transferDate.year}",
                style: const TextStyle(
                  color: Colors.white54,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            "\$${amount.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
