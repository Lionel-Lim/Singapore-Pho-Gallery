import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants.dart';
import 'shopping_list_page.dart';

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
      "title": "FairPrice",
      "weight": "250 g",
      "price": 2.50,
      "brand": "FairPrice",
    },
  ];

  List<String> _imageUrls = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchImages();
  }

  Future<void> _fetchImages() async {
    const apiKey = ' ';
    const searchEngineId = ' ';
    final url = Uri.parse(
        'https://www.googleapis.com/customsearch/v1?key=$apiKey&cx=$searchEngineId'
        '&q=${widget.ingredientName}&searchType=image&fileType=jpg&imgSize=medium&alt=json');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List<dynamic>;
        setState(() {
          _imageUrls =
              items.take(3).map((item) => item['link'] as String).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load images: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching images: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Widget _buildProductItem(BuildContext context, int index) {
    final product = _products[index];
    return Card(
      child: ListTile(
        leading: _imageUrls.length > index
            ? Image.network(
                _imageUrls[index],
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildPlaceholderImage(),
              )
            : _buildPlaceholderImage(),
        title: Text(
          "${widget.ingredientName} - ${product["title"]} - ${product["weight"]}",
          style: const TextStyle(fontFamily: kFontFamily),
        ),
        subtitle: Text(
          "\$${product["price"].toStringAsFixed(2)} - ${product["brand"]}",
          style: const TextStyle(fontFamily: kFontFamily),
        ),
        trailing: TextButton(
          onPressed: () {
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
  }

  Widget _buildPlaceholderImage() {
    return Image.asset(
      'assets/images/placeholder.png',
      width: 50,
      height: 50,
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.ingredientName,
          style: const TextStyle(fontFamily: kFontFamily),
        ),
        backgroundColor: kPrimaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (ctx) => const ShoppingListPage()),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _products.length,
                  itemBuilder: _buildProductItem,
                ),
    );
  }
}
