import 'package:flutter/material.dart';
import 'package:frontend/services/categories_service.dart';

class CategoriesCreateView extends StatefulWidget {
  const CategoriesCreateView({super.key});

  @override
  _CategoriesCreateViewState createState() => _CategoriesCreateViewState();
}

class _CategoriesCreateViewState extends State<CategoriesCreateView> {
  final TextEditingController _categoryNameController = TextEditingController();
  final CategoriesService _categoriesService = CategoriesService(); 

  String _categoryType ='expense'; 
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
    Colors.grey,
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
    Icons.travel_explore,
  ];

  Future<void> _addCategory() async {
    String categoryName = _categoryNameController.text;
    String categoryColor =
        '#${_selectedColor?.value.toRadixString(16).substring(2, 8)}'; 

    String categoryIcon = _selectedIcon != null
        ? _selectedIcon!.codePoint.toString()
        : 'default_icon'; 

    await _categoriesService.createCategory(
      categoryName,
      _categoryType,
      categoryColor,
      categoryIcon, 
    );

    Navigator.pop(context, true);
  }

  void _onColorSelected(Color color) {
    setState(() {
      _selectedColor = color;
    });
  }

  void _onIconSelected(IconData icon) {
    setState(() {
      _selectedIcon = icon;
      _selectedColor ??= const Color(
          0xFF191E29); 
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
                    value: 'expense', 
                    groupValue: _categoryType,
                    onChanged: (value) {
                      setState(() {
                        _categoryType = value!;
                      });
                    },
                    fillColor: WidgetStateProperty.all(Colors.white),
                  ),
                  const Text(
                    'Expenses',
                    style: TextStyle(color: Colors.white),
                  ),
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

              colorPicker(), 
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
                          iconData), 
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

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _addCategory, 
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
                    color), 
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
