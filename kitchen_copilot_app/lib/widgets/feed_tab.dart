import 'dart:convert';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/post.dart';
import 'post_widget.dart';

class FeedTab extends StatelessWidget {
  final String feedCategory;
  const FeedTab({super.key, required this.feedCategory});

  Future<List<Post>> _fetchPosts() async {
    if (kDebugMode) {
      return mockPosts;
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
