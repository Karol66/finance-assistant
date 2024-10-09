import 'package:flutter/material.dart';

class CardsCreateView extends StatefulWidget {
  const CardsCreateView({super.key});

  @override
  _CardsCreateViewState createState() => _CardsCreateViewState();
}

class _CardsCreateViewState extends State<CardsCreateView> {
  final TextEditingController _cardNameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _validThruController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();

  void _goToNextPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Scaffold(
          body: Center(child: Text("Next Page")),
        ),
      ),
    );
  }

  Widget inputTextField(String hintText, bool obscureText, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF132D46),
      appBar: AppBar(
        title: const Text('Create Card'),
        backgroundColor: const Color(0xFF0B6B3A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              inputTextField('Card Name', false, _cardNameController),
              const SizedBox(height: 20),

              inputTextField('Card Number', false, _cardNumberController),
              const SizedBox(height: 20),

              inputTextField('CVV', true, _cvvController),
              const SizedBox(height: 20),

              inputTextField('Valid Thru (MM/YY)', false, _validThruController),
              const SizedBox(height: 20),

              inputTextField('Bank Name', false, _bankNameController),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _goToNextPage,
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size.fromHeight(58),
                    backgroundColor: const Color(0xFF01C38D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Add Card',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
