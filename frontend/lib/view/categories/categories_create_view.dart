import 'package:flutter/material.dart';

class CategoriesCreateView extends StatefulWidget {
  const CategoriesCreateView({Key? key}) : super(key: key);

  @override
  _CategoriesCreateViewState createState() => _CategoriesCreateViewState();
}

class _CategoriesCreateViewState extends State<CategoriesCreateView> {
  // Kontrolery dla pól tekstowych
  final TextEditingController _categoryNameController = TextEditingController();
  final TextEditingController _plannedExpensesController = TextEditingController();

  // Wybrany typ kategorii
  String _categoryType = 'Expenses';

  // Wybór koloru
  Color? _selectedColor;

  // Wybór ikony
  IconData? _selectedIcon;

  // Lista dostępnych kolorów
  final List<Color> _colorOptions = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.brown,
    Colors.pink,
    Colors.grey,
  ];

  // Lista dostępnych ikon
  final List<IconData> _iconOptions = [
    Icons.directions_car,
    Icons.phone,
    Icons.bolt,
    Icons.flight,
    Icons.network_wifi,
    Icons.home,
    Icons.food_bank,
    Icons.school,
    Icons.health_and_safety,
    Icons.theater_comedy,
    Icons.shopping_bag,
    Icons.sports,
    Icons.work,
    Icons.forest,
    Icons.travel_explore,
  ];

  // Funkcja obsługująca wybór koloru
  void _onColorSelected(Color color) {
    setState(() {
      _selectedColor = color;
    });
  }

  // Funkcja obsługująca wybór ikony
  void _onIconSelected(IconData icon) {
    setState(() {
      _selectedIcon = icon;

      // Jeśli nie wybrano jeszcze koloru, ustaw domyślny kolor #191E29
      if (_selectedColor == null) {
        _selectedColor = const Color(0xFF191E29); // Domyślny kolor
      }
    });
  }

  // Funkcja nawigująca na inne strony (przykładowa)
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

  Widget inputTextField(
      String hintText, bool obscureText, TextEditingController controller) {
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

  // Widget przycisku "więcej"
  Widget moreButton() {
    return GestureDetector(
      onTap: () {
        print("More button pressed");
        // Możesz tutaj dodać logikę do wyświetlania większej liczby ikon
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFF494E59), // Szary kolor
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Center(
          child: Icon(
            Icons.more_horiz, // Ikona więcej (trzy kropki poziomo)
            size: 30,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF132D46),
      appBar: AppBar(
        title: const Text('Create Category'),
        backgroundColor: const Color.fromARGB(255, 0, 141, 73),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Powrót do poprzedniej strony
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Pole "Category Name"
              inputTextField('Category Name', false, _categoryNameController),
              const SizedBox(height: 20),

              // Pole "Planned Expenses"
              inputTextField(
                  'Planned Expenses', false, _plannedExpensesController),
              const SizedBox(height: 20),

              // Typ kategorii (przyciski radiowe)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Radio<String>(
                    value: 'Expenses',
                    groupValue: _categoryType,
                    onChanged: (value) {
                      setState(() {
                        _categoryType = value!;
                      });
                    },
                    fillColor: MaterialStateProperty.all(Colors.white),
                  ),
                  const Text(
                    'Expenses',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(width: 20), // Odległość między przyciskami
                  Radio<String>(
                    value: 'Income',
                    groupValue: _categoryType,
                    onChanged: (value) {
                      setState(() {
                        _categoryType = value!;
                      });
                    },
                    fillColor: MaterialStateProperty.all(Colors.white),
                  ),
                  const Text(
                    'Income',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Wybór koloru
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _colorOptions.map((color) {
                    return GestureDetector(
                      onTap: () => _onColorSelected(color),
                      child: Container(
                        width: 30,
                        height: 30,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(15),
                          border: _selectedColor == color
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Siatka ikon + przycisk "więcej"
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  ..._iconOptions.map((iconData) {
                    return GestureDetector(
                      onTap: () => _onIconSelected(iconData),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _selectedIcon == iconData
                              ? (_selectedColor ?? const Color(0xFF191E29))
                              : const Color(0xFF191E29),
                          borderRadius: BorderRadius.circular(15),
                          border: _selectedIcon == iconData
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                        ),
                        child: Icon(
                          iconData,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    );
                  }).toList(),

                  // Przycisk więcej
                  moreButton(),
                ],
              ),
              const SizedBox(height: 20),

              // Przycisk "Add"
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _goToNextPage, // Przejście na inną stronę
                  style: ElevatedButton.styleFrom(
                    fixedSize:
                        const Size.fromHeight(58), // Stała wysokość przycisku
                    backgroundColor:
                        const Color(0xFF01C38D), // Kolor tła przycisku
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8), // Zaokrąglenie krawędzi
                    ),
                  ),
                  child: const Text(
                    'Add', // Tekst przycisku
                    style: TextStyle(
                      fontSize: 16, // Rozmiar czcionki
                      fontWeight: FontWeight.bold, // Pogrubienie czcionki
                      color: Colors.white, // Kolor tekstu
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
