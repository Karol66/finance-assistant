import 'package:flutter/material.dart';
import 'package:frontend/services/categories_service.dart';

class CategoriesManageView extends StatefulWidget {
  final int categoryId;

  const CategoriesManageView({super.key, required this.categoryId});

  @override
  _CategoriesManageViewState createState() => _CategoriesManageViewState();
}

class _CategoriesManageViewState extends State<CategoriesManageView> {
  final TextEditingController _categoryNameController = TextEditingController();
  final CategoriesService _categoriesService = CategoriesService();

  String _categoryType = 'expense';
  Color? _selectedColor;
  IconData? _selectedIcon;

  final List<Color> _colorOptions = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.brown,
    Colors.pink,
    Colors.grey
  ];
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
    Icons.travel_explore
  ];

  @override
  void initState() {
    super.initState();
    _loadCategory();
  }

  Future<void> _loadCategory() async {
    final fetchedCategory =
        await _categoriesService.fetchCategoryById(widget.categoryId);
    if (fetchedCategory != null) {
      setState(() {
        _categoryNameController.text = fetchedCategory['category_name'];
        _categoryType = fetchedCategory['category_type'];
        _selectedColor = _parseColor(fetchedCategory['category_color']);
        _selectedIcon = _getIconFromString(fetchedCategory['category_icon']);
      });
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

  Future<void> _updateCategory() async {
    String categoryName = _categoryNameController.text;
    String categoryColor =
        '#${_selectedColor?.value.toRadixString(16).substring(2, 8)}';
    String categoryIcon = _selectedIcon != null
        ? _selectedIcon!.codePoint.toString()
        : 'default_icon';

    await _categoriesService.updateCategory(widget.categoryId, categoryName,
        _categoryType, categoryColor, categoryIcon);

    Navigator.pop(context, true);
  }

  Future<void> _deleteCategory() async {
    await _categoriesService.deleteCategory(widget.categoryId);

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF132D46),
      appBar: AppBar(
        title: const Text('Manage Category'),
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
              const Text(
                'Select Category Type:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Radio<String>(
                    value: 'expense',
                    groupValue: _categoryType,
                    onChanged: (value) {
                      setState(() {
                        _categoryType = value!;
                      });
                    },
                    fillColor: WidgetStateProperty.all(Colors.white),
                  ),
                  const Text('Expenses', style: TextStyle(color: Colors.white)),
                  const SizedBox(width: 20),
                  Radio<String>(
                    value: 'income',
                    groupValue: _categoryType,
                    onChanged: (value) {
                      setState(() {
                        _categoryType = value!;
                      });
                    },
                    fillColor: WidgetStateProperty.all(Colors.white),
                  ),
                  const Text('Income', style: TextStyle(color: Colors.white)),
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
              ),
              const SizedBox(height: 10),
              colorPicker(),
              const SizedBox(height: 20),
              const Text(
                'Select Category Icon:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
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
                        child: Icon(iconData, size: 40, color: Colors.white),
                      ),
                    );
                  }),
                  moreButton(),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updateCategory,
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size.fromHeight(58),
                    backgroundColor: const Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Update Category',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _deleteCategory,
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size.fromHeight(58),
                    backgroundColor: const Color(0xFFF44336),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Delete Category',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
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

  Widget colorPicker() {
    return SingleChildScrollView(
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
                shape: BoxShape.circle,
                border: Border.all(
                  color: (_selectedColor?.value == color.value)
                      ? Colors.white
                      : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _onColorSelected(Color color) {
    setState(() {
      _selectedColor = color;
    });
  }

  void _onIconSelected(IconData icon) {
    setState(() {
      _selectedIcon = icon;
    });
  }

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
