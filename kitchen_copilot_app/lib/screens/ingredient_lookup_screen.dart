import 'package:flutter/material.dart';
import '../constants.dart';
import 'shopping_list_page.dart'; // We'll define next

// Simple static cart
class ShoppingCart {
  static final List<String> items = [];
}

class IngredientLookUpScreen extends StatefulWidget {
  final String ingredientName;
  const IngredientLookUpScreen({super.key, required this.ingredientName});

  @override
  State<IngredientLookUpScreen> createState() => _IngredientLookUpScreenState();
}

class _IngredientLookUpScreenState extends State<IngredientLookUpScreen> {
  // Dummy list of available products for the ingredient.
  final List<Map<String, dynamic>> _products = [
    {
      "title": "Qian Fa Organic Farm",
      "weight": "300 g",
      "price": 2.90,
      "brand": "Qian Fa",
    },
    {
      "title": "Quan Fa Organic Farm 2",
      "weight": "300 g",
      "price": 3.20,
      "brand": "Quan Fa",
    },
    {
      "title": "FairPrice Strawberry Pack",
      "weight": "250 g",
      "price": 2.50,
      "brand": "FairPrice",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.ingredientName,
          style: const TextStyle(
            fontFamily: kFontFamily,
          ),
        ),
        backgroundColor: kPrimaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              // Navigate to shopping list page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (ctx) => const ShoppingListPage()),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return Card(
            child: ListTile(
              leading: Image.asset(
                'assets/images/placeholder.png',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              title: Text(
                "${product["title"]} - ${product["weight"]}",
                style: const TextStyle(fontFamily: kFontFamily),
              ),
              subtitle: Text(
                "\$${product["price"].toStringAsFixed(2)} - ${product["brand"]}",
                style: const TextStyle(fontFamily: kFontFamily),
              ),
              trailing: TextButton(
                onPressed: () {
                  // Add to cart
                  ShoppingCart.items
                      .add("${widget.ingredientName} - ${product["title"]}");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "${widget.ingredientName} added to cart!",
                        style: const TextStyle(fontFamily: kFontFamily),
                      ),
                    ),
                  );
                },
                child: const Text(
                  "Add to cart",
                  style: TextStyle(fontFamily: kFontFamily),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
