import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/post.dart';
import '../screens/recipe_placeholder_screen.dart';

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
              Expanded(flex: 6, child: _buildTitleAndContent()),
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
              Expanded(flex: 6, child: _buildTitleAndContent()),
              const SizedBox(width: 8),
              Expanded(
                  flex: 4,
                  child: Image.asset(post.imageUrl, fit: BoxFit.cover)),
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
