import 'package:flutter/material.dart';

class CardsView extends StatefulWidget {
  const CardsView({Key? key}) : super(key: key);

  @override
  _CardsViewState createState() => _CardsViewState();
}

class _CardsViewState extends State<CardsView> {
  List<Map<String, dynamic>> cards = [
    {
      "card_id": 1,
      "card_name": "John Doe",
      "card_number": "4532310099991049",
      "cvv": "123",
      "valid_thru": "12/25",
      "bank_name": "BANK NAME",
      "gradient_from": Colors.black87,
      "gradient_to": Colors.black54,
    },
    {
      "card_id": 2,
      "card_name": "Jane Smith",
      "card_number": "1234567812345678",
      "cvv": "456",
      "valid_thru": "01/30",
      "bank_name": "BANK NAME",
      "gradient_from": Colors.deepPurple,
      "gradient_to": Colors.purpleAccent,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF132D46), // Ciemne tło aplikacji
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  // Karty użytkownika
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cards.length,
                    itemBuilder: (context, index) {
                      final card = cards[index];
                      return _buildCardItem(card);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget dla pojedynczej karty
  Widget _buildCardItem(Map<String, dynamic> card) {
    return GestureDetector(
      onTap: () {
        print("Manage card: ${card['card_name']}");
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(20),
        width: MediaQuery.of(context).size.width * 0.9,
        height: 200, // Zwiększona wysokość kart, aby więcej przestrzeni było na napisy
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [card['gradient_from'], card['gradient_to']],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end, // Napisy znajdują się bliżej dolnej części
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Górna część karty: Nazwa banku i typ karty (przyciśnięte niżej)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  card['bank_name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "Credit Card",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20), // Zwiększony odstęp dla lepszego rozmieszczenia

            // Ikona chipu i numer karty (przyciśnięte do dolnej części)
            Row(
              children: [
                // Chip karty
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/chip.png'), // Zastąp ścieżką do ikony chipu
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 20),

                // Numer karty w formacie 4x4
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${card['card_number'].substring(0, 4)} ${card['card_number'].substring(4, 8)} ${card['card_number'].substring(8, 12)} ${card['card_number'].substring(12, 16)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 5),
                    // CVV zamiast ostatnich czterech cyfr
                    Text(
                      "CVV: ${card['cvv']}",
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 15), // Dodany odstęp przed dolną częścią

            // Dolna część karty: Data ważności i imię posiadacza karty
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "VALID THRU",
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      card['valid_thru'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  card['card_name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
