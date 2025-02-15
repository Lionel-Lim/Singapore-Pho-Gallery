import 'dart:convert';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Define common constants
const kPrimaryColor = Color(0xFFF05637);
const kFABColor = Color.fromARGB(255, 41, 90, 24);
const kFontFamily = 'Inter';

void main() => runApp(const CommunityApp());

class CommunityApp extends StatelessWidget {
  const CommunityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kitchen Copilot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: kPrimaryColor,
        fontFamily: kFontFamily,
      ),
      home: const HomeScreen(),
    );
  }
}

// --------------------------
// Home Screen with Bottom Navigation
// --------------------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 4; // default: Community
  final List<Widget> _pages = const [
    PlaceholderPage(title: 'My Plan'),
    PlaceholderPage(title: 'List'),
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
      floatingActionButton: Padding(
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

// --------------------------
// Placeholder pages for non-Community tabs
// --------------------------
class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 24, color: Colors.white),
      ),
    );
  }
}

// --------------------------
// Community Page (with TabBar for Follow, Explore, Nearby)
// --------------------------
class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Follow, Explore, Nearby
      child: Scaffold(
        backgroundColor: kPrimaryColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight * 2.484),
          child: AppBar(
            backgroundColor: kPrimaryColor,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Center(
                      child: Text(
                        'COMMUNITY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          fontFamily: kFontFamily,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chat, color: Colors.white),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Chat tapped')),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications,
                            color: Colors.white),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Alarm tapped')),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Menu tapped')),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 35,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: TabBar(
                        indicator: BoxDecoration(
                          color: Colors.white,
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: kPrimaryColor,
                        unselectedLabelColor: Colors.white,
                        unselectedLabelStyle: TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                        tabs: [
                          Tab(text: 'FOLLOW'),
                          Tab(text: 'EXPLORE'),
                          Tab(text: 'NEARBY'),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            color: Colors.white,
            child: const TabBarView(
              children: [
                FeedTab(feedCategory: 'Follow'),
                FeedTab(feedCategory: 'Explore'),
                FeedTab(feedCategory: 'Nearby'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --------------------------
// Feed Tab: Lists posts
// --------------------------
class FeedTab extends StatelessWidget {
  final String feedCategory;
  const FeedTab({super.key, required this.feedCategory});

  Future<List<Post>> _fetchPosts() async {
    if (kDebugMode) {
      return mockPosts; // Use mock posts in debug
    } else {
      final uri = Uri.parse(
          'https://<YOUR-FIREBASE-FUNCTIONS-ENDPOINT>/posts?category=$feedCategory');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Post.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load posts');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Post>>(
      future: _fetchPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No posts found'));
        } else {
          final posts = snapshot.data!;
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) => PostWidget(post: posts[index]),
          );
        }
      },
    );
  }
}

// --------------------------
// Post Model & Mock Data
// --------------------------
enum PostStyle { bigImage, leftImage, rightImage }

class Post {
  final String userName;
  final String userAvatar;
  final String postTime;
  final String title;
  final String content;
  final String imageUrl;
  final PostStyle style;
  bool isLiked;

  Post({
    required this.userName,
    required this.userAvatar,
    required this.postTime,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.style,
    this.isLiked = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        userName: json['userName'] ?? 'Unknown User',
        userAvatar: json['userAvatar'] ?? '',
        postTime: json['postTime'] ?? '',
        title: json['title'] ?? '',
        content: json['content'] ?? '',
        imageUrl: json['imageUrl'] ?? '',
        style: PostStyle.values[json['style'] ?? 0],
        isLiked: json['isLiked'] ?? false,
      );
}

final mockPosts = <Post>[
  Post(
    userName: 'Kitchen Copilot',
    userAvatar: 'assets/images/placeholder.png',
    postTime: '4 MONTHS AGO',
    title: 'SPINACH BREAKFAST',
    content:
        'Chef Mark’s Spinach Breakfast mixes grains, toast, and creamy avocado for a perfect start.',
    imageUrl: 'assets/images/placeholder.png',
    style: PostStyle.bigImage,
  ),
  Post(
    userName: 'Kitchen Copilot',
    userAvatar: 'assets/images/placeholder.png',
    postTime: '4 MONTHS AGO',
    title: 'CAESAR SALAD',
    content:
        'Freshly made with bacon, croutons, and parmesan – a classic Caesar salad.',
    imageUrl: 'assets/images/placeholder.png',
    style: PostStyle.leftImage,
  ),
  Post(
    userName: 'Kitchen Copilot',
    userAvatar: 'assets/images/placeholder.png',
    postTime: '2 MONTHS AGO',
    title: 'CHICKEN SOUP',
    content: 'A hearty chicken soup perfect for any day.',
    imageUrl: 'assets/images/placeholder.png',
    style: PostStyle.rightImage,
  ),
];

// --------------------------
// Post Widget
// --------------------------
class PostWidget extends StatefulWidget {
  final Post post;
  const PostWidget({super.key, required this.post});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  late Post post;

  @override
  void initState() {
    super.initState();
    post = widget.post;
  }

  void _toggleLike() {
    setState(() => post.isLiked = !post.isLiked);
  }

  void _onSeeRecipe() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RecipePlaceholderScreen()),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(post.userAvatar),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.userName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: kFontFamily,
                ),
              ),
              Text(
                post.postTime,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontFamily: kFontFamily,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildTitleAndContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          post.title.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            fontFamily: kFontFamily,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          post.content,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: kFontFamily,
          ),
        ),
      ],
    );
  }

  Widget _buildButtonRow() {
    return Row(
      children: [
        TextButton.icon(
          onPressed: _toggleLike,
          icon: Icon(
            post.isLiked ? Icons.favorite : Icons.favorite_border,
            color: post.isLiked ? Colors.red : Colors.grey,
          ),
          label: Text(
            post.isLiked ? 'Liked' : 'Like',
            style: const TextStyle(fontFamily: kFontFamily),
          ),
        ),
        const Spacer(),
        OutlinedButton(
          onPressed: _onSeeRecipe,
          child: const Text(
            'SEE RECIPE',
            style: TextStyle(fontFamily: kFontFamily),
          ),
        ),
      ],
    );
  }

  Widget _buildBigImageStyle() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderRow(),
          const SizedBox(height: 8),
          Image.asset(post.imageUrl, fit: BoxFit.cover),
          const SizedBox(height: 8),
          _buildTitleAndContent(),
          const SizedBox(height: 8),
          _buildButtonRow(),
        ],
      ),
    );
  }

  Widget _buildLeftImageStyle() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderRow(),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: Image.asset(post.imageUrl, fit: BoxFit.cover),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 6,
                child: _buildTitleAndContent(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildButtonRow(),
        ],
      ),
    );
  }

  Widget _buildRightImageStyle() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderRow(),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 6,
                child: _buildTitleAndContent(),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: Image.asset(post.imageUrl, fit: BoxFit.cover),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildButtonRow(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (post.style) {
      case PostStyle.bigImage:
        return _buildBigImageStyle();
      case PostStyle.leftImage:
        return _buildLeftImageStyle();
      case PostStyle.rightImage:
        return _buildRightImageStyle();
    }
  }
}

// --------------------------
// Recipe Placeholder Screen
// --------------------------
class RecipePlaceholderScreen extends StatelessWidget {
  const RecipePlaceholderScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RECIPE', style: TextStyle(fontFamily: kFontFamily)),
        backgroundColor: kPrimaryColor,
      ),
      body: const Center(
        child: Text(
          'Recipe Screen Placeholder',
          style: TextStyle(fontSize: 18, fontFamily: kFontFamily),
        ),
      ),
    );
  }
}
