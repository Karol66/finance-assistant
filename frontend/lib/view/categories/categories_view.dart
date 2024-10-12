import 'package:flutter/material.dart';
import 'package:frontend/services/categories_service.dart';
import 'package:frontend/view/categories/categories_create_view.dart';
import 'package:frontend/view/categories/categories_manage_view.dart'; // Import widoku zarządzania kategorią

class CategoriesView extends StatefulWidget {
  const CategoriesView({super.key});

  @override
  _CategoriesViewState createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView> {
  bool isExpenses = true;
  List<Map<String, dynamic>> categories = [];

  final CategoriesService _categoriesService = CategoriesService(); // Serwis do obsługi kategorii

  @override
  void initState() {
    super.initState();
    loadCategories(isExpenses ? "expense" : "income");  // Załaduj kategorie odpowiedniego typu
  }

  // Funkcja do pobierania kategorii z serwera
  Future<void> loadCategories(String categoryType) async {
    final fetchedCategories = await _categoriesService.fetchCategories();
    
    if (fetchedCategories != null) {
      setState(() {
        categories = fetchedCategories
            .where((category) => category["category_type"] == categoryType)
            .map((category) => {
                  "category_id": category["id"],
                  "category_name": category["category_name"],
                  "category_type": category["category_type"],
                  "category_color": _parseColor(category["category_color"]),
                  "category_icon": _getIconFromString(category["category_icon"]),
                })
            .toList();
      });
    } else {
      print("Failed to load categories.");
    }
  }

  // Funkcja do konwersji stringa na ikonę
  IconData _getIconFromString(String iconString) {
    int codePoint = int.tryParse(iconString) ?? 0;
    return IconData(codePoint, fontFamily: 'MaterialIcons');
  }

  // Funkcja do parsowania koloru w formacie hex
  Color _parseColor(String colorString) {
    return Color(int.parse(colorString.substring(1, 7), radix: 16) + 0xFF000000);
  }

  // Funkcja obsługująca przełączanie pomiędzy Expenses i Income
  void onLinkClick(bool showExpenses) {
    setState(() {
      isExpenses = showExpenses;
      categories.clear(); // Wyczyść listę kategorii przed załadowaniem nowych
      loadCategories(isExpenses ? "expense" : "income");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF132D46), // Tło widoku
      body: Column(
        children: [
          // Przełączniki Expenses i Income
          Row(
            children: [
              const SizedBox(height: 60),  // Dystans dla górnej krawędzi
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    onLinkClick(true); // Ustaw Expenses
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isExpenses ? Colors.white : Colors.transparent, // Zmienny kolor zależny od wyboru
                          width: 2.0,
                        ),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Expenses",
                      style: TextStyle(
                        color: isExpenses ? Colors.white : Colors.grey[600],  // Kolor tekstu zależny od wyboru
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    onLinkClick(false); // Ustaw Income
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: !isExpenses ? Colors.white : Colors.transparent,  // Zmienny kolor zależny od wyboru
                          width: 2.0,
                        ),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Income",
                      style: TextStyle(
                        color: !isExpenses ? Colors.white : Colors.grey[600],  // Kolor tekstu zależny od wyboru
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),  // Dystans poniżej przełączników
          // Siatka kategorii
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // Liczba kolumn
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount:
                  categories.length + 1, // Dodajemy dodatkowy element dla przycisku dodawania
              itemBuilder: (context, index) {
                if (index == categories.length) {
                  return createAddButton(); // Przycisk dodawania kategorii
                }
                final category = categories[index];
                return categoryItem(category); // Wyświetlanie kategorii
              },
            ),
          ),
        ],
      ),
    );
  }

// Widget dla pojedynczej kategorii z nawigacją do podstrony zarządzania
Widget categoryItem(Map<String, dynamic> category) {
  return GestureDetector(
    onTap: () async {
      // Nawigacja do ekranu zarządzania kategorią po kliknięciu
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CategoriesManageView(
            categoryId: category["category_id"], // Przekazujemy ID kategorii
          ),
        ),
      );
      // Odświeżenie kategorii po powrocie z ekranu zarządzania kategorią
      if (result == true) {
        loadCategories(isExpenses ? "expense" : "income");
      }
    },
    child: Container(
      decoration: BoxDecoration(
        color: category["category_color"], // Użycie koloru kategorii
        borderRadius: BorderRadius.circular(15), // Zaokrąglenie rogów
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(category["category_icon"], size: 30, color: Colors.white), // Wyświetlanie ikony kategorii
          const SizedBox(height: 5),
          Text(
            category["category_name"], // Wyświetlanie nazwy kategorii
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  );
}

  // Widget przycisku dodawania kategorii
  Widget createAddButton() {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CategoriesCreateView(), // Przejście do ekranu tworzenia kategorii
          ),
        );
        // Odświeżenie kategorii po powrocie z ekranu tworzenia kategorii
        if (result == true) {
          loadCategories(isExpenses ? "expense" : "income");
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF01C38D), // Kolor dla przycisku dodawania
          borderRadius: BorderRadius.circular(15), // Zaokrąglenie rogów
        ),
        child: const Icon(Icons.add, size: 30, color: Colors.white), // Ikona dodawania
      ),
    );
  }
}
