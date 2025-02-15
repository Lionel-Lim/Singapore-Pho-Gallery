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

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
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
