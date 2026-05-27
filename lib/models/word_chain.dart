class WordChain {
  final int? id;
  final String userId;
  final List<String> words;
  final String story;
  final String? imageUrl;
  final DateTime? createdAt;

  WordChain({
    this.id,
    required this.userId,
    required this.words,
    required this.story,
    this.imageUrl,
    this.createdAt,
  });

  factory WordChain.fromJson(Map<String, dynamic> json) {
    return WordChain(
      id: json['id'] as int?,
      userId: json['user_id'] as String,
      words: (json['words'] as List<dynamic>).cast<String>(),
      story: json['story'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'user_id': userId,
        'words': words,
        'story': story,
        if (imageUrl != null) 'image_url': imageUrl,
      };
}
