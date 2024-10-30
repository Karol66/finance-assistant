import 'package:flutter/material.dart';
import 'package:frontend/services/categories_service.dart';
import 'package:frontend/view/categories/categories_create_view.dart';
import 'package:frontend/view/categories/categories_manage_view.dart';

class CategoriesView extends StatefulWidget {
  const CategoriesView({super.key});

  @override
  _CategoriesViewState createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView> {
  bool isExpenses = true;
  List<Map<String, dynamic>> categories = [];

  final CategoriesService _categoriesService = CategoriesService();

  @override
  void initState() {
    super.initState();
    loadCategories(isExpenses ? "expense" : "income");
  }

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
                  "category_icon":
                      _getIconFromString(category["category_icon"]),
                })
            .toList();
      });
    } else {
      print("Failed to load categories.");
    }
  }

  IconData _getIconFromString(String iconString) {
    int codePoint = int.tryParse(iconString) ?? 0;
    return IconData(codePoint, fontFamily: 'MaterialIcons');
  }

  Color _parseColor(String colorString) {
    return Color(
        int.parse(colorString.substring(1, 7), radix: 16) + 0xFF000000);
  }

  void onLinkClick(bool showExpenses) {
    setState(() {
      isExpenses = showExpenses;
      categories.clear();
      loadCategories(isExpenses ? "expense" : "income");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF132D46),
      body: Column(
        children: [
          Row(
            children: [
              const SizedBox(height: 60),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    onLinkClick(true);
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
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    onLinkClick(false);
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
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: categories.length + 1,
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
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoriesManageView(
              categoryId: category["category_id"],
            ),
          ),
        );
        if (result == true) {
          loadCategories(isExpenses ? "expense" : "income");
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: category["category_color"],
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
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CategoriesCreateView(),
          ),
        );
        if (result == true) {
          loadCategories(isExpenses ? "expense" : "income");
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF01C38D),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
    );
  }
}
