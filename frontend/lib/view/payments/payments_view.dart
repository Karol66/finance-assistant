import 'package:flutter/material.dart';

class RegularPaymentsView extends StatefulWidget {
  const RegularPaymentsView({super.key});

  @override
  _RegularPaymentsViewState createState() => _RegularPaymentsViewState();
}

class _RegularPaymentsViewState extends State<RegularPaymentsView> {
  // Przykładowe dane dla regularnych płatności
  List<Map<String, dynamic>> payments = [
    {
      "id": 1,
      "amount": 5.99,
      "payment_date": DateTime(2023, 1, 30),
      "description": "Spotify Subscription",
      "icon": Icons.music_note,
      "category_color": Colors.green,
    },
    {
      "id": 2,
      "amount": 18.99,
      "payment_date": DateTime(2023, 1, 30),
      "description": "YouTube Premium",
      "icon": Icons.video_collection,
      "category_color": Colors.red,
    },
    {
      "id": 3,
      "amount": 9.99,
      "payment_date": DateTime(2023, 2, 2),
      "description": "Netflix Subscription",
      "icon": Icons.movie,
      "category_color": Colors.orange,
    },
    {
      "id": 4,
      "amount": 29.99,
      "payment_date": DateTime(2023, 2, 5),
      "description": "Microsoft 365",
      "icon": Icons.computer,
      "category_color": Colors.blue,
    },
  ];

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF132D46),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Szary element na górze z kalendarzem
            Container(
              width: media.width,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF191E29),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: _buildCalendarView(), // Kalendarz
            ),
            const SizedBox(height: 20),
            _buildPaymentsList(), // Lista płatności
          ],
        ),
      ),
    );
  }

  // Widok kalendarza (prosty kalendarz z datami)
  Widget _buildCalendarView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (index) {
          DateTime today = DateTime.now();
          DateTime date = today.add(Duration(days: index));

          return Column(
            children: [
              Text(
                _getWeekday(date),
                style: const TextStyle(
                  fontSize: 16, // Minimalnie zwiększona wielkość nazw dni tygodnia
                  fontWeight: FontWeight.bold,
                  color: Colors.white54,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(12), // Minimalnie zwiększony padding
                decoration: BoxDecoration(
                  color: date.day == today.day
                      ? Colors.orange
                      : Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "${date.day}",
                  style: const TextStyle(
                    fontSize: 18, // Minimalnie zwiększona wielkość numeru dnia
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

  // Pomocnicza funkcja do konwersji daty na nazwę dnia tygodnia
  String _getWeekday(DateTime date) {
    const weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return weekdays[date.weekday - 1];
  }

  // Widok listy płatności
  Widget _buildPaymentsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: payments.length,
        itemBuilder: (context, index) {
          final payment = payments[index];
          return _buildPaymentItem(payment);
        },
      ),
    );
  }

  // Widok pojedynczej płatności
  Widget _buildPaymentItem(Map<String, dynamic> payment) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF191E29), // Kolor tła dla karty
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 40, // Przywrócono oryginalną wielkość ikony kategorii
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: payment['category_color'],
            ),
            child: Icon(payment['icon'], color: Colors.white, size: 20), // Przywrócono oryginalną wielkość ikony
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                payment['description'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${payment['payment_date'].day}/${payment['payment_date'].month}/${payment['payment_date'].year}",
                style: const TextStyle(
                  color: Colors.white54,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            "\$${payment['amount'].toStringAsFixed(2)}",
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
