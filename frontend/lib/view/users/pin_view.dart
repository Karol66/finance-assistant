import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PinView extends StatefulWidget {
  const PinView({super.key});

  @override
  _PinViewState createState() => _PinViewState();
}

class _PinViewState extends State<PinView> {
  // Kontrolery dla każdego pola
  final TextEditingController _pinController1 = TextEditingController();
  final TextEditingController _pinController2 = TextEditingController();
  final TextEditingController _pinController3 = TextEditingController();
  final TextEditingController _pinController4 = TextEditingController();

  // FocusNodes do automatycznego przejścia między polami
  final FocusNode _focusNode1 = FocusNode();
  final FocusNode _focusNode2 = FocusNode();
  final FocusNode _focusNode3 = FocusNode();
  final FocusNode _focusNode4 = FocusNode();

  // Funkcja do walidacji i zapisania PINu
  void _savePin() {
    final pin = _pinController1.text + _pinController2.text + _pinController3.text + _pinController4.text;

    if (pin.length != 4) {
      // Jeśli PIN nie ma 4 cyfr, wyświetl alert
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Invalid PIN"),
            content: const Text("PIN must be exactly 4 digits."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Zamknięcie alertu
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    } else {
      // Logika zapisu PINu
      print('PIN saved: $pin');
      Navigator.pop(context); // Powrót po zapisaniu PINu
    }
  }

  Widget buildPinBox(TextEditingController controller, FocusNode currentFocus, FocusNode? nextFocus) {
    return SizedBox(
      width: 50,
      child: TextField(
        controller: controller,
        focusNode: currentFocus,
        obscureText: true, // Ukrywanie PINu
        maxLength: 1, // Tylko jedna cyfra
        keyboardType: TextInputType.number, // Klawiatura numeryczna
        textAlign: TextAlign.center,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly, // Tylko cyfry
        ],
        decoration: InputDecoration(
          counterText: '', // Usunięcie licznika znaków
          filled: true,
          fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          if (value.length == 1) {
            // Automatyczne przejście do następnego pola, jeśli wpisano cyfrę
            if (nextFocus != null) {
              FocusScope.of(context).requestFocus(nextFocus);
            } else {
              FocusScope.of(context).unfocus(); // Zakończenie, jeśli to ostatnie pole
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF132D46), // Kolor tła
      appBar: AppBar(
        title: const Text('Set PIN'),
        backgroundColor: const Color(0xFF0B6B3A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Enter a 4-digit PIN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // 4 pola na PIN obok siebie
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildPinBox(_pinController1, _focusNode1, _focusNode2),
                  buildPinBox(_pinController2, _focusNode2, _focusNode3),
                  buildPinBox(_pinController3, _focusNode3, _focusNode4),
                  buildPinBox(_pinController4, _focusNode4, null),
                ],
              ),
              const SizedBox(height: 20),

              // Przycisk do zapisania PINu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _savePin,
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size.fromHeight(58),
                    backgroundColor: const Color(0xFF01C38D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Save PIN',
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
