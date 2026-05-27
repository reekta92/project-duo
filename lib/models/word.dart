class Word {
  final int? wordId;
  final String engWordName;
  final String turWordName;
  final String? picture;
  final DateTime? createdAt;

  const Word({
    this.wordId,
    required this.engWordName,
    required this.turWordName,
    this.picture,
    this.createdAt,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      wordId: json['word_id'] as int?,
      engWordName: (json['name_en'] as String?) ?? '',
      turWordName: (json['name_tr'] as String?) ?? '',
      picture: json['image_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (wordId != null) 'word_id': wordId,
        'name_en': engWordName,
        'name_tr': turWordName,
        if (picture != null) 'image_url': picture,
      };
}
