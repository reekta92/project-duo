import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/word.dart';
import '../models/quiz_progress.dart';
import '../models/quiz_session.dart';
import 'word_service.dart';
import 'settings_service.dart';

class QuizService {
  static final _client = Supabase.instance.client;
  final WordService _wordService = WordService();
  final SettingsService _settingsService = SettingsService();

  /// Fetch words due for review (next_review_at <= now and not mastered)
  Future<List<Word>> getDueWords(String userId) async {
    final data = await _client
        .from('quiz_progress')
        .select('word_id')
        .eq('user_id', userId)
        .eq('is_mastered', false)
        .lte('next_review_at', DateTime.now().toIso8601String());

    if (data.isEmpty) return [];

    final wordIds =
        (data as List).map<int>((d) => d['word_id'] as int).toList();

    final words = <Word>[];
    for (final id in wordIds) {
      try {
        words.add(await _wordService.getWord(id));
      } catch (_) {}
    }
    return words;
  }

  /// Fetch N new words the user hasn't seen before
  Future<List<Word>> getNewWords(String userId, int count) async {
    // Get word IDs already in quiz_progress
    final seenData = await _client
        .from('quiz_progress')
        .select('word_id')
        .eq('user_id', userId);

    final seenIds =
        (seenData as List).map<int>((d) => d['word_id'] as int).toSet();

    // Get all words
    final allWords = await _wordService.getWords(limit: 500);
    final newWords =
        allWords.where((w) => !seenIds.contains(w.wordId)).toList();

    if (newWords.isEmpty) return [];

    final random = Random();
    newWords.shuffle(random);
    return newWords.take(count).toList();
  }

  /// Build today's quiz list (due words + new words)
  Future<List<Word>> buildQuiz(String userId) async {
    final settings = await _settingsService.loadSettings();
    final dailyNewCount = settings.dailyNewWordCount;

    final dueWords = await getDueWords(userId);
    final newWords = await getNewWords(userId, dailyNewCount);

    final all = [...dueWords, ...newWords];
    final random = Random();
    all.shuffle(random);
    return all;
  }

  /// Get 3 random wrong answers (distractors) for a Turkish word
  Future<List<String>> getDistractors(String correctTurkish,
      {int count = 3}) async {
    final allWords = await _wordService.getWords(limit: 200);
    final turkishWords = allWords
        .map((w) => w.turWordName)
        .where((t) => t != correctTurkish)
        .toList();

    final random = Random();
    turkishWords.shuffle(random);
    return turkishWords.take(count).toList();
  }

  /// Submit an answer and update progress
  Future<QuizProgress> submitAnswer(
      String userId, int wordId, bool isCorrect) async {
    // Get or create progress record
    final data = await _client
        .from('quiz_progress')
        .select()
        .eq('user_id', userId)
        .eq('word_id', wordId)
        .maybeSingle();

    QuizProgress progress;
    if (data != null) {
      progress = QuizProgress.fromJson(data);
    } else {
      progress = QuizProgress(
        userId: userId,
        wordId: wordId,
      );
    }

    // Update stats
    progress.totalAttempts++;
    if (isCorrect) progress.totalCorrect++;
    progress.lastAnsweredAt = DateTime.now();

    // 6-repetition algorithm
    if (progress.isMastered) {
      // Already mastered, no further updates needed
    } else if (progress.reviewLevel == 0) {
      // Learning phase
      if (isCorrect) {
        progress.consecutiveCorrect++;
        if (progress.consecutiveCorrect >= 6) {
          // Move to review phase
          progress.reviewLevel = 1;
          progress.consecutiveCorrect = 0;
          progress.nextReviewAt = _getNextReviewDate(1);
        } else {
          // Still in learning, review tomorrow
          progress.nextReviewAt =
              DateTime.now().add(const Duration(days: 1));
        }
      } else {
        // Wrong answer resets streak
        progress.consecutiveCorrect = 0;
        progress.nextReviewAt = DateTime.now();
      }
    } else {
      // Review phase (levels 1-6)
      if (isCorrect) {
        if (progress.reviewLevel >= 6) {
          // Mastered!
          progress.isMastered = true;
          progress.nextReviewAt = DateTime.now().add(const Duration(days: 365));
        } else {
          progress.reviewLevel++;
          progress.nextReviewAt =
              _getNextReviewDate(progress.reviewLevel);
        }
      } else {
        // Wrong answer in review → reset to learning phase
        progress.reviewLevel = 0;
        progress.consecutiveCorrect = 0;
        progress.nextReviewAt = DateTime.now();
      }
    }

    progress.updatedAt = DateTime.now();

    // Upsert to DB
    await _client.from('quiz_progress').upsert(progress.toJson());

    return progress;
  }

  /// Calculate next review date based on spaced repetition level
  DateTime _getNextReviewDate(int level) {
    final now = DateTime.now();
    switch (level) {
      case 1:
        return now.add(const Duration(days: 1));
      case 2:
        return now.add(const Duration(days: 7));
      case 3:
        return now.add(const Duration(days: 30));
      case 4:
        return now.add(const Duration(days: 90));
      case 5:
        return now.add(const Duration(days: 180));
      case 6:
        return now.add(const Duration(days: 365));
      default:
        return now.add(const Duration(days: 1));
    }
  }

  /// Start a new quiz session
  Future<int> startSession(String userId) async {
    final session = QuizSession(
      userId: userId,
      startedAt: DateTime.now(),
    );
    final data =
        await _client.from('quiz_sessions').insert(session.toJson()).select();
    return (data as List).first['id'] as int;
  }

  /// End session and save stats
  Future<void> endSession(int sessionId, int totalQuestions,
      int correctAnswers, int durationSeconds) async {
    await _client.from('quiz_sessions').update({
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'wrong_answers': totalQuestions - correctAnswers,
      'duration_seconds': durationSeconds,
      'completed_at': DateTime.now().toIso8601String(),
    }).eq('id', sessionId);
  }

  /// Save answer log
  Future<void> saveAnswer(
      int sessionId, String userId, int wordId,
      String selectedAnswer, String correctAnswer, bool isCorrect) async {
    await _client.from('quiz_answers').insert({
      'session_id': sessionId,
      'user_id': userId,
      'word_id': wordId,
      'selected_answer': selectedAnswer,
      'correct_answer': correctAnswer,
      'is_correct': isCorrect,
      'answered_at': DateTime.now().toIso8601String(),
    });
  }

  /// Get total mastered count for a user
  Future<int> getMasteredCount(String userId) async {
    final data = await _client
        .from('quiz_progress')
        .select('id')
        .eq('user_id', userId)
        .eq('is_mastered', true);
    return (data as List).length;
  }

  /// Get total in-progress count
  Future<int> getInProgressCount(String userId) async {
    final data = await _client
        .from('quiz_progress')
        .select('id')
        .eq('user_id', userId)
        .eq('is_mastered', false);
    return (data as List).length;
  }

  /// Get overall accuracy
  Future<double> getOverallAccuracy(String userId) async {
    final data = await _client
        .from('quiz_progress')
        .select('total_attempts,total_correct')
        .eq('user_id', userId);

    int total = 0;
    int correct = 0;
    for (final row in data) {
      total += (row['total_attempts'] as int?) ?? 0;
      correct += (row['total_correct'] as int?) ?? 0;
    }
    return total > 0 ? correct / total * 100 : 0;
  }

  /// Get session history
  Future<List<QuizSession>> getSessionHistory(String userId,
      {int limit = 20}) async {
    final data = await _client
        .from('quiz_sessions')
        .select()
        .eq('user_id', userId)
        .order('started_at', ascending: false)
        .limit(limit);
    return (data as List).map<QuizSession>((d) => QuizSession.fromJson(d)).toList();
  }
}
