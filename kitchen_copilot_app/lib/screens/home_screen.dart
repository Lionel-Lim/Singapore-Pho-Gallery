import 'package:flutter/material.dart';
import 'package:kitchen_copilot_app/screens/myplan_page.dart';
import 'package:kitchen_copilot_app/screens/shopping_list_page.dart';
import '../constants.dart';
import 'placeholder_page.dart';
import 'community_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 4; // default: Community
  final List<Widget> _pages = const [
    MyPlanPage(),
    // PlaceholderPage(title: 'My Plan'),
    ShoppingListPage(),
    PlaceholderPage(title: 'Recipes'),
    PlaceholderPage(title: 'Cook'),
    CommunityPage(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  // Floating action button for New Post
  void _onNewPost() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('New Post tapped')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: kPrimaryColor,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'My Plan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Recipes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_dining),
            label: 'Cook',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Community',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 4
          ? Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: SizedBox(
                height: 40,
                child: FloatingActionButton.extended(
                  onPressed: _onNewPost,
                  backgroundColor: kFABColor,
                  icon: const Icon(Icons.add, color: Colors.white, size: 20),
                  label: const Text(
                    'New Post',
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
