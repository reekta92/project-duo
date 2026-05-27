class QuizSession {
  final int? id;
  final String userId;
  int totalQuestions;
  int correctAnswers;
  int wrongAnswers;
  int? durationSeconds;
  final DateTime? startedAt;
  DateTime? completedAt;

  QuizSession({
    this.id,
    required this.userId,
    this.totalQuestions = 0,
    this.correctAnswers = 0,
    this.wrongAnswers = 0,
    this.durationSeconds,
    this.startedAt,
    this.completedAt,
  });

  factory QuizSession.fromJson(Map<String, dynamic> json) {
    return QuizSession(
      id: json['id'] as int?,
      userId: json['user_id'] as String,
      totalQuestions: (json['total_questions'] as int?) ?? 0,
      correctAnswers: (json['correct_answers'] as int?) ?? 0,
      wrongAnswers: (json['wrong_answers'] as int?) ?? 0,
      durationSeconds: json['duration_seconds'] as int?,
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'user_id': userId,
        'total_questions': totalQuestions,
        'correct_answers': correctAnswers,
        'wrong_answers': wrongAnswers,
        'duration_seconds': durationSeconds,
        'started_at': startedAt?.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
      };

  double get accuracy =>
      totalQuestions > 0 ? correctAnswers / totalQuestions * 100 : 0;
}
