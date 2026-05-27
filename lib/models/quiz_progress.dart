class QuizProgress {
  final int? id;
  final String userId;
  final int wordId;
  int consecutiveCorrect;
  int reviewLevel;
  DateTime nextReviewAt;
  DateTime? lastAnsweredAt;
  bool isMastered;
  int totalAttempts;
  int totalCorrect;
  final DateTime? createdAt;
  DateTime? updatedAt;

  QuizProgress({
    this.id,
    required this.userId,
    required this.wordId,
    this.consecutiveCorrect = 0,
    this.reviewLevel = 0,
    DateTime? nextReviewAt,
    this.lastAnsweredAt,
    this.isMastered = false,
    this.totalAttempts = 0,
    this.totalCorrect = 0,
    this.createdAt,
    this.updatedAt,
  }) : nextReviewAt = nextReviewAt ?? DateTime.now();

  factory QuizProgress.fromJson(Map<String, dynamic> json) {
    return QuizProgress(
      id: json['id'] as int?,
      userId: json['user_id'] as String,
      wordId: json['word_id'] as int,
      consecutiveCorrect: (json['consecutive_correct'] as int?) ?? 0,
      reviewLevel: (json['review_level'] as int?) ?? 0,
      nextReviewAt: json['next_review_at'] != null
          ? DateTime.parse(json['next_review_at'] as String)
          : DateTime.now(),
      lastAnsweredAt: json['last_answered_at'] != null
          ? DateTime.parse(json['last_answered_at'] as String)
          : null,
      isMastered: (json['is_mastered'] as bool?) ?? false,
      totalAttempts: (json['total_attempts'] as int?) ?? 0,
      totalCorrect: (json['total_correct'] as int?) ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'user_id': userId,
        'word_id': wordId,
        'consecutive_correct': consecutiveCorrect,
        'review_level': reviewLevel,
        'next_review_at': nextReviewAt.toIso8601String(),
        'last_answered_at': lastAnsweredAt?.toIso8601String(),
        'is_mastered': isMastered,
        'total_attempts': totalAttempts,
        'total_correct': totalCorrect,
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      };
}
