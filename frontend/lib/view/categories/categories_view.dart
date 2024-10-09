import 'package:flutter/material.dart';
import 'package:frontend/view/categories/categories_create_view.dart';

class CategoryController {
  List<Map<String, dynamic>> getUserCategories(String userId) {
    // Przykładowe dane kategorii, zastąp to faktycznym pobieraniem danych
    return [
      {
        "category_id": 1,
        "category_name": "Groceries",
        "category_type": "Expenses",
        "category_color": Colors.blue, // Kolor kategorii zostaje bez zmian
        "category_icon": Icons.shopping_cart,
      },
      {
        "category_id": 2,
        "category_name": "Salary",
        "category_type": "Income",
        "category_color": Colors.green, // Kolor kategorii zostaje bez zmian
        "category_icon": Icons.attach_money,
      },
    ];
  }

  Map<String, dynamic>? getCategoryById(int categoryId) {
    // Zastąp tym co faktycznie pobiera dane kategorii
    return getUserCategories('user_id')
        .firstWhere((category) => category["category_id"] == categoryId);
  }
}

class CategoriesView extends StatefulWidget {
  const CategoriesView({Key? key}) : super(key: key);

  @override
  _CategoriesViewState createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView> {
  bool isExpenses = true;

  final CategoryController _categoryController = CategoryController();
  List<Map<String, dynamic>> categories = [];

  @override
  void initState() {
    super.initState();
    loadCategories(isExpenses ? "Expenses" : "Income");
  }

  void onLinkClick(bool showExpenses) {
    setState(() {
      isExpenses = showExpenses;
      categories.clear();
      loadCategories(isExpenses ? "Expenses" : "Income");
    });
  }

  void manageCategoryClick(int categoryId) {
    // Obsłuż logikę po kliknięciu kategorii, np. przejście do edycji
    final category = _categoryController.getCategoryById(categoryId);
    if (category != null) {
      print("Zarządzaj kategorią: ${category['category_name']}");
    }
  }

  void createCategoryClick() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const CategoriesCreateView(), 
      ),
    );
  }

  void loadCategories(String categoryType) {
    final allCategories = _categoryController.getUserCategories('user_id');
    setState(() {
      categories = allCategories
          .where((category) => category["category_type"] == categoryType)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF132D46), // Zmienione tylko tło całego widoku
      body: Column(
        children: [
          // Przełączniki Expenses i Income
          Row(
            children: [
              const SizedBox(height: 70),
              // Przełącznik Expenses
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    onLinkClick(true); // Ustawiamy Expenses
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isExpenses ? Colors.white : Colors.transparent,
                          width: 2.0,
                        ),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Expenses",
                      style: TextStyle(
                        color: isExpenses ? Colors.white : Colors.grey[600],
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              // Przełącznik Income
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    onLinkClick(false); // Ustawiamy Income
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color:
                              !isExpenses ? Colors.white : Colors.transparent,
                          width: 2.0,
                        ),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Income",
                      style: TextStyle(
                        color: !isExpenses ? Colors.white : Colors.grey[600],
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          // Siatka kategorii
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // Ustawienie liczby kolumn na 4
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount:
                  categories.length + 1, // Dodajemy 1 na przycisk dodawania
              itemBuilder: (context, index) {
                if (index == categories.length) {
                  return createAddButton();
                }
                final category = categories[index];
                return categoryItem(category);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget categoryItem(Map<String, dynamic> category) {
    return GestureDetector(
      onTap: () => manageCategoryClick(category["category_id"]),
      child: Container(
        decoration: BoxDecoration(
          color: category["category_color"], // Pozostawiony kolor kategorii
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(category["category_icon"], size: 30, color: Colors.white),
            const SizedBox(height: 5),
            Text(
              category["category_name"],
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

  Widget createAddButton() {
    return GestureDetector(
      onTap: createCategoryClick,
      child: Container(
        decoration: BoxDecoration(
          color:
              const Color(0xFF01C38D), // Zielony kolor dla przycisku dodawania
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
    );
  }
}
