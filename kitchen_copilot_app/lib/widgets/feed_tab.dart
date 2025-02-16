import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/post.dart';
import 'post_widget.dart';

class FeedTab extends StatelessWidget {
  final String feedCategory;
  const FeedTab({super.key, required this.feedCategory});

  Future<List<Post>> _fetchPosts() async {
    // Use your backend URL here. Adjust if your route differs (e.g. /get-all-posts).
    final uri = Uri.parse('http://127.0.0.1:8000/get-all-posts');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Post.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load posts');
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
          // Filter posts based on feedCategory (Follow, explorer, community)
          final filteredPosts = posts
              .where((post) =>
                  post.postType.toLowerCase() == feedCategory.toLowerCase())
              .toList();
          return ListView.builder(
            itemCount: filteredPosts.length,
            itemBuilder: (context, index) =>
                PostWidget(post: filteredPosts[index]),
          );
        }
      },
    );
  }
}
