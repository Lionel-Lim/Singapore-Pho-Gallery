enum PostStyle { bigImage, leftImage, rightImage }

class Post {
  final String postType;
  final String description;
  final String createdAt;
  final String imageUrl;
  final int likeCount;
  final String title;
  final String userId;
  final String mealId;
  final Location location;
  final List<String> likes;
  final String postId;
  PostStyle postStyle;
  bool isLiked;

  Post({
    required this.postType,
    required this.description,
    required this.createdAt,
    required this.imageUrl,
    required this.likeCount,
    required this.title,
    required this.userId,
    required this.mealId,
    required this.location,
    required this.likes,
    required this.postId,
    this.postStyle = PostStyle.leftImage,
    this.isLiked = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      postType: json['post_type'],
      description: json['description'],
      createdAt: json['created_at'],
      imageUrl: json['image_url'],
      likeCount: json['like_count'],
      title: json['title'],
      userId: json['user_id'],
      mealId: json['meal_id'],
      location: Location.fromJson(json['location']),
      likes: List<String>.from(json['likes']),
      postId: json['post_id'],
    );
  }
}

class Location {
  final double latitude;
  final double longitude;

  Location({required this.latitude, required this.longitude});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}

// final mockPosts = <Post>[
//   Post(
//     userName: 'Kitchen Copilot',
//     userAvatar: 'assets/images/placeholder.png',
//     postTime: '4 MONTHS AGO',
//     title: 'SPINACH BREAKFAST',
//     content:
//         'Chef Mark’s Spinach Breakfast mixes grains, toast, and creamy avocado for a perfect start.',
//     imageUrl: 'assets/images/placeholder.png',
//     style: PostStyle.bigImage,
//   ),
//   Post(
//     userName: 'Kitchen Copilot',
//     userAvatar: 'assets/images/placeholder.png',
//     postTime: '4 MONTHS AGO',
//     title: 'CAESAR SALAD',
//     content:
//         'Freshly made with bacon, croutons, and parmesan – a classic Caesar salad.',
//     imageUrl: 'assets/images/placeholder.png',
//     style: PostStyle.leftImage,
//   ),
//   Post(
//     userName: 'Kitchen Copilot',
//     userAvatar: 'assets/images/placeholder.png',
//     postTime: '2 MONTHS AGO',
//     title: 'CHICKEN SOUP',
//     content: 'A hearty chicken soup perfect for any day.',
//     imageUrl: 'assets/images/placeholder.png',
//     style: PostStyle.rightImage,
//   ),
// ];
