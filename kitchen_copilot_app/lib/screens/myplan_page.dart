import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:intl/intl.dart'; // for date formatting
import 'package:http/http.dart' as http;
import '../constants.dart';
import 'recipe_page.dart'; // kPrimaryColor, kFontFamily

// Simple model for a Meal.
class Meal {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  Meal({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
  });
}

class MyPlanPage extends StatefulWidget {
  const MyPlanPage({super.key});
  @override
  State<MyPlanPage> createState() => _MyPlanPageState();
}

class _MyPlanPageState extends State<MyPlanPage> {
  // For generating actual dates instead of "Monday, Tuesday..."
  late List<DateTime> _weekDates;

  // Meal times to be displayed.
  final List<String> _mealTimes = ['Breakfast', 'Lunch', 'Dinner'];

  final List<String> _examples = [
    "1 week meal plan with high protein without beef",
    "Easy meal plan for a busy week",
    "Spicy recipe for stressful day",
  ];

  // Summary text and meal plan data from backend.
  String? _summary;
  // Meal plan: day -> mealTime -> Meal.
  Map<String, Map<String, Meal>> _mealPlan = {};

  // Flags for generation process.
  bool _isGenerating = false;
  bool _showCreatedWidget = false;
  bool _showConfigOverlay = false; // toggled via cog button

  // Currently selected cell for configuration.
  String? _selectedDateKey;
  String? _selectedMealTime;

  // Predefined alternative meals (dummy data).
  final List<Meal> _alternativeMeals = [
    Meal(
      id: 'alt1',
      name: 'Grilled Chicken Salad',
      description: 'Healthy salad with grilled chicken, avocado, and tomatoes.',
      imageUrl: 'assets/images/placeholder.png',
    ),
    Meal(
      id: 'alt2',
      name: 'Vegan Buddha Bowl',
      description: 'A colorful mix of quinoa, roasted veggies, and chickpeas.',
      imageUrl: 'assets/images/placeholder.png',
    ),
  ];

  // Controller for custom prompt input.
  final TextEditingController _promptController = TextEditingController();

  // Notification messages and demo meal id.
  final List<String> _notifications = [];
  String? _demoMealId;

  @override
  void initState() {
    super.initState();
    // Figure out the "start of the week" (Monday).
    final now = DateTime.now();
    // weekday in Dart: Monday=1, Sunday=7.
    final int currentWeekday = now.weekday;
    final monday = now.subtract(Duration(days: currentWeekday - 1));
    // Build a list of 7 dates: Monday to Sunday.
    _weekDates = List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  /// Fetch the meal plan from the backend.
  Future<void> _fetchMealPlanFromBackend() async {
    setState(() {
      _isGenerating = true;
    });
    try {
      final uri = Uri.parse('http://127.0.0.1:8000/demo-meal-plan');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          _summary = data['summary'];
          final mealPlanData = data['mealPlan'] as Map<String, dynamic>;
          _mealPlan = {};
          // For each day (e.g., "Monday", "Tuesday", etc.)
          mealPlanData.forEach((day, meals) {
            final mealsMap = meals as Map<String, dynamic>;
            Map<String, Meal> dayMeals = {};
            mealsMap.forEach((mealTime, mealJson) {
              dayMeals[mealTime] = Meal(
                id: mealJson['id'],
                name: mealJson['name'],
                description: "", // No description provided from backend.
                imageUrl: mealJson['imageUrl'],
              );
            });
            _mealPlan[day] = dayMeals;
          });
          _isGenerating = false;
          _showCreatedWidget = true;
        });
        // Hide the created widget overlay after a delay.
        await Future.delayed(const Duration(seconds: 2));
        setState(() {
          _showCreatedWidget = false;
        });
      } else {
        setState(() {
          _isGenerating = false;
        });
        throw Exception('Failed to load meal plan');
      }
    } catch (error) {
      setState(() {
        _isGenerating = false;
      });
      // Handle error appropriately (e.g., show a Snackbar or AlertDialog).
      rethrow;
    }
  }

  // Updated _generatePlan simply calls the backend.
  Future<void> _generatePlan(String prompt) async {
    await _fetchMealPlanFromBackend();
  }

  // Helper to produce a date key like '2023-08-21'
  String _formatDateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  // For display, e.g. "Mon, Aug 21"
  String _displayDate(DateTime date) => DateFormat('E, MMM d').format(date);

  void _navigateToRecipe(Meal meal) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RecipeScreen(recipeId: meal.id),
      ),
    );
  }

  // Handler for when a selectable example is tapped.
  void _onExampleTap(String example) {
    _promptController.text = example;
    _generatePlan(example);
  }

  // Handler for "Generate" button.
  void _onGenerateTap() {
    final prompt = _promptController.text.trim();
    if (prompt.isNotEmpty) {
      _generatePlan(prompt);
    }
  }

  // Handler for "Regenerate" button in summary.
  Future<void> _regeneratePlan() async {
    await _generatePlan("Regenerate");
  }

  // Show draggable configuration overlay for a meal cell.
  void _showMealConfigOverlay(String dateKey, String mealTime) {
    _selectedDateKey = dateKey;
    _selectedMealTime = mealTime;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.4,
          maxChildSize: 0.75,
          expand: false,
          builder: (context, scrollController) {
            return MealConfigOverlay(
              scrollController: scrollController,
              alternatives: _alternativeMeals,
              onSelect: (Meal selectedMeal) {
                setState(() {
                  _mealPlan[dateKey]![mealTime] = selectedMeal;
                });
                // Simulate backend update if needed.
                Navigator.of(context).pop();
              },
            );
          },
        );
      },
    );
  }

  // Handler for chat demo.
  void _onChatDemo() {
    if (_mealPlan.isEmpty) return;
    final anyDay = _mealPlan.keys.first;
    final anyMealTime = _mealPlan[anyDay]!.keys.first;
    final selectedMeal = _mealPlan[anyDay]![anyMealTime];
    if (selectedMeal != null) {
      setState(() {
        _demoMealId = selectedMeal.id;
        _notifications.add(
            "Try ${selectedMeal.name} at home this week within 20 mins. Fresh ingredients are ready for you.");
      });
    }
  }

  // Handler for notifications tap.
  void _onNotificationsTap() {
    if (_notifications.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Notifications"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _notifications.map((msg) => Text(msg)).toList(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // App bar with title and action icons.
    final appBar = PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight * 2.484),
      child: AppBar(
        backgroundColor: kPrimaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title.
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Center(
                  child: Text(
                    'MY PLAN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      fontFamily: kFontFamily,
                    ),
                  ),
                ),
              ),
              // Action icons.
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chat, color: Colors.white),
                    onPressed: _onChatDemo,
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.white),
                    onPressed: _onNotificationsTap,
                  ),
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () {},
                  ),
                  if (_mealPlan.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _showConfigOverlay = !_showConfigOverlay;
                        });
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: appBar,
      backgroundColor: Colors.white,
      body: _mealPlan.isEmpty ? _buildAIAssistant() : _buildMealPlanScreen(),
    );
  }

  // AI assistant UI when no plan exists.
  Widget _buildAIAssistant() {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Kitchen Copilot icon.
              const CircleAvatar(
                radius: 40,
                backgroundImage:
                    AssetImage('assets/images/kitchen_copliot_icon.png'),
                backgroundColor: Colors.transparent,
              ),
              const SizedBox(height: 16),
              const Text(
                'Create your Meal with Kitchen Copilot',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  fontFamily: kFontFamily,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Select Examples or describe your need',
                style: TextStyle(fontSize: 16, fontFamily: kFontFamily),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Examples list.
              Column(
                children: _examples.map((example) {
                  return InkWell(
                    onTap: () => _onExampleTap(example),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: kPrimaryColor, width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 30,
                          child: Marquee(
                            text: example,
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: kFontFamily,
                            ),
                            blankSpace: MediaQuery.of(context).size.width / 2,
                            pauseAfterRound: const Duration(seconds: 3),
                            startAfter: const Duration(seconds: 15),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              // Prompt input.
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: kPrimaryColor, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    TextField(
                      controller: _promptController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText:
                            'Describe in detail what you want to achieve in your meal plan',
                        border: InputBorder.none,
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF285A17),
                        ),
                        onPressed: _isGenerating ? null : _onGenerateTap,
                        child: const Text('Generate',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (_isGenerating) const CircularProgressIndicator(),
            ],
          ),
        ),
        if (_showCreatedWidget)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 80),
                    SizedBox(height: 16),
                    Text(
                      'Your Plan is Created',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: kFontFamily,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Meal plan screen with summary and grid.
  Widget _buildMealPlanScreen() {
    return Column(
      children: [
        // Summary panel.
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: kPrimaryColor),
            color: Colors.white,
          ),
          child: Column(
            children: [
              Text(
                _summary ?? '',
                style: const TextStyle(fontSize: 16, fontFamily: kFontFamily),
              ),
              const SizedBox(height: 20),
              Container(
                alignment: Alignment.topRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF285A17),
                  ),
                  onPressed: _isGenerating ? null : _regeneratePlan,
                  child: const Text('Regenerate',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
        // Meal plan grid.
        Expanded(
          child: Container(
            color: Colors.grey[200],
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Table(
                  border: TableBorder.all(color: kPrimaryColor),
                  columnWidths: const {
                    0: FixedColumnWidth(80),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: _buildMealPlanRows(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<TableRow> _buildMealPlanRows() {
    List<TableRow> rows = [];
    // Header row: empty first cell then meal times.
    rows.add(
      TableRow(
        children: [
          TableCell(
            child: Container(
              color: Colors.grey[400],
              padding: const EdgeInsets.all(8.0),
              child: const Text(
                '',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: kFontFamily,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ..._mealTimes.map((time) => TableCell(
                child: Container(
                  color: Colors.grey[400],
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    time,
                    style: const TextStyle(
                      fontFamily: kFontFamily,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )),
        ],
      ),
    );

    // For each date in _weekDates.
    for (var date in _weekDates) {
      // Use the day name (e.g., Monday) as key to look up the meal.
      final dayName = DateFormat('EEEE').format(date);
      final dateKey = _formatDateKey(date);
      rows.add(
        TableRow(
          children: [
            // Date column.
            TableCell(
              child: Container(
                color: Colors.grey[400],
                height: 100,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RotatedBox(
                      quarterTurns: -1,
                      child: Text(
                        _displayDate(date),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontFamily: kFontFamily,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Meal time columns.
            ..._mealTimes.map((mealTime) {
              final meal = _mealPlan[dayName]?[mealTime];
              return TableCell(
                child: GestureDetector(
                  onTap: meal == null ? null : () => _navigateToRecipe(meal),
                  child: SizedBox(
                    height: 100,
                    child: Stack(
                      children: [
                        // Meal image (network or fallback asset).
                        Positioned.fill(
                          child: meal != null &&
                                  meal.imageUrl.startsWith("http")
                              ? Image.network(meal.imageUrl, fit: BoxFit.cover)
                              : Image.asset(
                                  'assets/images/placeholder.png',
                                  fit: BoxFit.cover,
                                ),
                        ),
                        // Meal name overlay.
                        if (meal != null)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              color: Colors.black38,
                              height: 20,
                              child: meal.name.length > 20
                                  ? Marquee(
                                      text: meal.name,
                                      style: const TextStyle(
                                        fontFamily: kFontFamily,
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                      blankSpace: 50,
                                      pauseAfterRound:
                                          const Duration(seconds: 2),
                                    )
                                  : Text(
                                      meal.name,
                                      style: const TextStyle(
                                        fontFamily: kFontFamily,
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                            ),
                          ),
                        // Config overlay icon.
                        if (_showConfigOverlay)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.settings,
                                  size: 16, color: Colors.red),
                              onPressed: () =>
                                  _showMealConfigOverlay(dayName, mealTime),
                            ),
                          ),
                        // "Try at Home" ribbon.
                        if (meal != null && meal.id == _demoMealId)
                          Positioned(
                            top: 0,
                            left: 0,
                            child: Container(
                              color: Colors.orange,
                              padding: const EdgeInsets.all(4),
                              child: const Text(
                                "Try at Home",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      );
    }
    return rows;
  }
}

// Draggable overlay widget for configuring a meal cell.
class MealConfigOverlay extends StatefulWidget {
  final ScrollController? scrollController;
  final List<Meal> alternatives;
  final ValueChanged<Meal> onSelect;
  const MealConfigOverlay({
    super.key,
    this.scrollController,
    required this.alternatives,
    required this.onSelect,
  });
  @override
  State<MealConfigOverlay> createState() => _MealConfigOverlayState();
}

class _MealConfigOverlayState extends State<MealConfigOverlay> {
  final TextEditingController _searchController = TextEditingController();
  List<Meal> _results = [];

  @override
  void initState() {
    super.initState();
    _results = widget.alternatives;
  }

  void _onSearch(String query) async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _results = widget.alternatives
          .where(
              (meal) => meal.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search alternative meals...',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: kPrimaryColor),
              ),
            ),
            onChanged: _onSearch,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              controller: widget.scrollController,
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final meal = _results[index];
                return Card(
                  child: ListTile(
                    leading: meal.imageUrl.startsWith("http")
                        ? Image.network(
                            meal.imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            meal.imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                    title: Text(meal.name,
                        style: const TextStyle(fontFamily: kFontFamily)),
                    subtitle: Text(meal.description,
                        style: const TextStyle(fontFamily: kFontFamily)),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF285A17),
                      ),
                      onPressed: () {
                        widget.onSelect(meal);
                      },
                      child: const Text('Select',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
