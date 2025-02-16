import 'package:flutter/material.dart';
import 'package:kitchen_copilot_app/screens/recipe_page.dart';
import '../constants.dart';
import '../models/post.dart';
import 'package:html_unescape/html_unescape.dart';

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
      MaterialPageRoute(builder: (_) => RecipeScreen(recipeId: post.mealId)),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      children: [
        const CircleAvatar(
          backgroundImage: AssetImage("assets/images/profile.png"),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.userId,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: kFontFamily,
                ),
              ),
              Text(
                post.createdAt,
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
          HtmlUnescape().convert(post.title),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            fontFamily: kFontFamily,
          ),
        ),
        Text(
          (() {
            final description = HtmlUnescape().convert(post.description);
            // Remove a trailing escaped quote if present.
            return description.endsWith('"')
                ? description.substring(0, description.length - 1)
                : description;
          })(),
          style: const TextStyle(fontSize: 14, fontFamily: kFontFamily),
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
          child: const Text('SEE RECIPE',
              style: TextStyle(fontFamily: kFontFamily)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use post.postType to determine which style to show.
    switch (post.postType.toLowerCase()) {
      case 'follow':
        return _buildFollowStyle();
      case 'explore':
        return _buildExplorerStyle();
      case 'nearby':
        return _buildNearbyStyle();
      default:
        return _buildExplorerStyle();
    }
  }

  // New style for "follow" posts: image on the left.
  Widget _buildFollowStyle() {
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
                child: Image.network(post.imageUrl, fit: BoxFit.cover),
              ),
              const SizedBox(width: 8),
              Expanded(flex: 6, child: _buildTitleAndContent()),
            ],
          ),
          const SizedBox(height: 8),
          _buildButtonRow(),
        ],
      ),
    );
  }

  // New style for "explore" posts: big image style.
  Widget _buildExplorerStyle() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderRow(),
          const SizedBox(height: 8),
          Image.network(post.imageUrl, fit: BoxFit.cover),
          const SizedBox(height: 8),
          _buildTitleAndContent(),
          const SizedBox(height: 8),
          _buildButtonRow(),
        ],
      ),
    );
  }

  // New style for "nearby" posts: image on the right.
  Widget _buildNearbyStyle() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderRow(),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(flex: 6, child: _buildTitleAndContent()),
              const SizedBox(width: 8),
              Expanded(
                  flex: 4,
                  child: Image.network(post.imageUrl, fit: BoxFit.cover)),
            ],
          ),
          const SizedBox(height: 8),
          _buildButtonRow(),
        ],
      ),
    );
  }
}
