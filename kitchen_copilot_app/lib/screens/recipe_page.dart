import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import '../constants.dart'; // kPrimaryColor, kFontFamily
import 'ingredient_lookup_screen.dart'; // We'll define next

class Recipe {
  final String id;
  final String title;
  final String imageUrl;
  final String sourceName;
  final String sourceUrl;
  final int prepTime; // in minutes
  final int cookTime; // in minutes
  final int servings;
  final List<IngredientSection> ingredientsSections;
  final List<String> instructions;
  final String notes;

  Recipe({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.sourceName,
    required this.sourceUrl,
    required this.prepTime,
    required this.cookTime,
    required this.servings,
    required this.ingredientsSections,
    required this.instructions,
    required this.notes,
  });
}

class IngredientSection {
  final String sectionName;
  final List<IngredientItem> items;

  IngredientSection({required this.sectionName, required this.items});
}

class IngredientItem {
  final String name;
  final String quantity; // e.g. "12 pcs", "2 l"

  IngredientItem({required this.name, required this.quantity});
}

class RecipeScreen extends StatefulWidget {
  final String recipeId;
  const RecipeScreen({super.key, required this.recipeId});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen>
    with SingleTickerProviderStateMixin {
  late Future<Recipe> _recipeFuture;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _recipeFuture = _fetchRecipe(widget.recipeId);
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Simulated backend call to fetch the recipe data. Replace with real API call.
  Future<Recipe> _fetchRecipe(String recipeId) async {
    await Future.delayed(const Duration(seconds: 1));
    // Return dummy data
    return Recipe(
      id: recipeId,
      title: "NORMANDY CREPES",
      imageUrl: "https://somecdn.com/crepes.jpg",
      sourceName: "cookingqueen.com",
      sourceUrl: "http://www.cookingqueen.com",
      prepTime: 30,
      cookTime: 30,
      servings: 4,
      ingredientsSections: [
        IngredientSection(
          sectionName: "Ingredients for crust",
          items: [
            IngredientItem(name: "Eggs", quantity: "12 pcs"),
            IngredientItem(name: "Milk", quantity: "2 l"),
            IngredientItem(name: "Strawberries", quantity: "200 g"),
          ],
        ),
        IngredientSection(
          sectionName: "Ingredients for topping",
          items: [
            IngredientItem(name: "Sugar", quantity: "50 g"),
            IngredientItem(name: "Butter", quantity: "2 tbsp"),
          ],
        ),
      ],
      instructions: [
        "Mix the crust ingredients thoroughly",
        "Cook on medium heat for 15 minutes",
        "Add topping as desired",
      ],
      notes: "Extra notes here about the recipe.",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "INSTRUCTION",
          style: TextStyle(
            fontFamily: kFontFamily,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        backgroundColor: kPrimaryColor,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "INGREDIENTS"),
            Tab(text: "INSTRUCTIONS"),
            Tab(text: "NOTES"),
          ],
          // Set the lable color to white
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey[300],
        ),
      ),
      body: Container(
        color: Colors.white,
        child: FutureBuilder<Recipe>(
          future: _recipeFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(fontFamily: kFontFamily),
                ),
              );
            } else if (!snapshot.hasData) {
              return const Center(child: Text('No data found'));
            } else {
              final recipe = snapshot.data!;
              return TabBarView(
                controller: _tabController,
                children: [
                  // 1) Ingredients Tab
                  _buildIngredientsTab(recipe),
                  // 2) Instructions Tab
                  _buildInstructionsTab(recipe),
                  // 3) Notes Tab
                  _buildNotesTab(recipe),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  // ----------------------------
  // Ingredients Tab
  // ----------------------------
  Widget _buildIngredientsTab(Recipe recipe) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(recipe),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "For ${recipe.servings} Serving(s)",
              style: const TextStyle(
                fontFamily: kFontFamily,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...recipe.ingredientsSections.map((section) {
            return _buildIngredientSection(section);
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Each ingredient section
  Widget _buildIngredientSection(IngredientSection section) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.sectionName,
            style: const TextStyle(
              fontFamily: kFontFamily,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          // For each item in this section
          ...section.items.map(
            (item) => InkWell(
              onTap: () {
                // Navigate to ingredient look up screen
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => IngredientLookUpScreen(
                      ingredientName: item.name,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.name,
                        style: const TextStyle(fontFamily: kFontFamily)),
                    Text(item.quantity,
                        style: const TextStyle(fontFamily: kFontFamily)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------
  // Instructions Tab
  // ----------------------------
  Widget _buildInstructionsTab(Recipe recipe) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(recipe),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Instructions",
              style: TextStyle(
                fontFamily: kFontFamily,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(recipe.instructions.length, (i) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                "${i + 1}. ${recipe.instructions[i]}",
                style: const TextStyle(fontFamily: kFontFamily),
              ),
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ----------------------------
  // Notes Tab
  // ----------------------------
  Widget _buildNotesTab(Recipe recipe) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(recipe),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Notes",
              style: TextStyle(
                fontFamily: kFontFamily,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              recipe.notes,
              style: const TextStyle(fontFamily: kFontFamily),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ----------------------------
  // Header: Dish image, name, times, etc.
  // ----------------------------
  Widget _buildHeader(Recipe recipe) {
    final totalTime = recipe.prepTime + recipe.cookTime;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.network(
            recipe.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey,
              child: const Center(child: Text('Image not available')),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Title with possible marquee
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: (recipe.title.length > 25)
              ? SizedBox(
                  height: 30,
                  child: Marquee(
                    text: recipe.title,
                    style: const TextStyle(
                      fontFamily: kFontFamily,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    blankSpace: 50,
                    pauseAfterRound: const Duration(seconds: 2),
                  ),
                )
              : Text(
                  recipe.title,
                  style: const TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Source: ${recipe.sourceName}",
            style: const TextStyle(fontFamily: kFontFamily, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 8),
        // Times
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                "$totalTime min Total",
                style: const TextStyle(fontFamily: kFontFamily),
              ),
              const SizedBox(width: 8),
              Text(
                "${recipe.prepTime} min Preparation",
                style: const TextStyle(fontFamily: kFontFamily),
              ),
              const SizedBox(width: 8),
              Text(
                "${recipe.cookTime} min Cooking",
                style: const TextStyle(fontFamily: kFontFamily),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: handle add to plan
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Added to plan!')),
                    );
                  },
                  child: const Text('ADD TO PLAN',
                      style: TextStyle(fontFamily: kFontFamily)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: handle start cooking
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Starting cooking!')),
                    );
                  },
                  child: const Text('START COOKING',
                      style: TextStyle(fontFamily: kFontFamily)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
