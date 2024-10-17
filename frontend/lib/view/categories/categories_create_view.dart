import 'package:flutter/material.dart';
import 'package:frontend/services/categories_service.dart';

class CategoriesCreateView extends StatefulWidget {
  const CategoriesCreateView({super.key});

  @override
  _CategoriesCreateViewState createState() => _CategoriesCreateViewState();
}

class _CategoriesCreateViewState extends State<CategoriesCreateView> {
  final TextEditingController _categoryNameController = TextEditingController();
  final TextEditingController _plannedExpensesController = TextEditingController();
  final CategoriesService _categoriesService = CategoriesService(); // Utwórz instancję serwisu

  String _categoryType ='expense'; // Ustawienie domyślnego typu kategorii jako 'expense'
  Color? _selectedColor; // Zmienna przechowująca wybrany kolor
  IconData? _selectedIcon; // Zmienna przechowująca wybraną ikonę

  // Opcje kolorów do wyboru
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

  // Opcje ikon do wyboru
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

  // Metoda do tworzenia nowej kategorii
  Future<void> _addCategory() async {
    // Pobranie danych z formularza
    String categoryName = _categoryNameController.text;
    String plannedExpenses = double.parse(_plannedExpensesController.text)
        .toStringAsFixed(2); // Upewnij się, że jest to liczba dziesiętna
    String categoryColor =
        '#${_selectedColor?.value.toRadixString(16).substring(2, 8)}'; // Poprawa formatu koloru (6 znaków)

    // Przypisanie wybranej ikony przez użytkownika, jeśli została wybrana, lub domyślnej wartości
    String categoryIcon = _selectedIcon != null
        ? _selectedIcon!.codePoint.toString()
        : 'default_icon'; // Wybrana ikona lub 'default_icon'

    // Wywołanie serwisu, aby utworzyć kategorię
    await _categoriesService.createCategory(
      categoryName,
      _categoryType,
      plannedExpenses,
      categoryColor,
      categoryIcon, // Przekazujemy wybraną lub domyślną ikonę
    );

      // Po utworzeniu kategorii wracamy do poprzedniego ekranu i zwracamy wartość true
    Navigator.pop(context, true);
  }

  // Metoda do wyboru koloru
  void _onColorSelected(Color color) {
    setState(() {
      _selectedColor = color;
    });
  }

  // Metoda do wyboru ikony
  void _onIconSelected(IconData icon) {
    setState(() {
      _selectedIcon = icon;
      _selectedColor ??= const Color(
          0xFF191E29); // Ustawienie domyślnego koloru, jeśli nie wybrano wcześniej
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF132D46),
      appBar: AppBar(
        title: const Text('Create Category'),
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
              inputTextField('Category Name', false, _categoryNameController),
              const SizedBox(height: 20),

              inputTextField(
                  'Planned Expenses', false, _plannedExpensesController),
              const SizedBox(height: 20),

              const Text(
                'Select Category Type:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Radio<String>(
                    value: 'expense', // Użyj małych liter zgodnie z Django
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
                  const SizedBox(width: 20),
                  Radio<String>(
                    value: 'income', // Użyj małych liter zgodnie z Django
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

              const Text(
                'Select Category Color:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 10),

              colorPicker(), // Wybór koloru
              const SizedBox(height: 20),

              const Text(
                'Select Category Icon:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 20),

              // Grid do wyboru ikony
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  ..._iconOptions.map((iconData) {
                    return GestureDetector(
                      onTap: () => _onIconSelected(
                          iconData), // Zmieniono na przypisanie wybranej ikony
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
                  }),
                  moreButton(),
                ],
              ),
              const SizedBox(height: 20),

              // Przycisk dodania kategorii
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _addCategory, // Wywołanie metody dodawania kategorii
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size.fromHeight(58),
                    backgroundColor: const Color(0xFF01C38D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Add Category',
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

  // Widget do wprowadzania tekstu
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

  // Widget do wyboru koloru
  Widget colorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _colorOptions.map((color) {
              return GestureDetector(
                onTap: () => _onColorSelected(
                    color), // Zmieniono na przypisanie wybranego koloru
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
      ],
    );
  }

  // Przycisk "More"
  Widget moreButton() {
    return GestureDetector(
      onTap: () {
        print("More button pressed");
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFF494E59),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Center(
          child: Icon(
            Icons.more_horiz,
            size: 30,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
