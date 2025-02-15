import 'package:flutter/material.dart';
import '../constants.dart';
import 'ingredient_lookup_screen.dart' show ShoppingCart; // use the static cart

class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({super.key});

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  @override
  Widget build(BuildContext context) {
    final items = ShoppingCart.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Shopping List',
          style: TextStyle(fontFamily: kFontFamily),
        ),
        backgroundColor: kPrimaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              setState(() {
                ShoppingCart.items.clear();
              });
            },
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: items.isEmpty
          ? const Center(
              child: Text(
                'Your shopping list is empty.',
                style: TextStyle(fontFamily: kFontFamily),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  child: ListTile(
                    title: Text(item,
                        style: const TextStyle(fontFamily: kFontFamily)),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          ShoppingCart.items.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
