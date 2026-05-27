import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';

enum LetterStatus { correct, present, absent }

class WordleService {
  static final _client = Supabase.instance.client;

  /// Pick a random word from the user's seen words (exactly 5 letters)
  Future<Map<String, dynamic>?> getWordleWord(String userId) async {
    // Get word IDs from quiz_progress where user has attempted
    final progressData = await _client
        .from('quiz_progress')
        .select('word_id')
        .eq('user_id', userId)
        .gt('total_attempts', 0);

    if (progressData.isEmpty) return null;

    final wordIds =
        (progressData as List).map<int>((d) => d['word_id'] as int).toList();

    // Fetch the words, filter by exactly 5 letters
    final wordsData = await _client
        .from('words')
        .select('word_id, name_en, name_tr')
        .inFilter('word_id', wordIds);

    var candidates = (wordsData as List).where((w) {
      final en = (w['name_en'] as String?) ?? '';
      return en.length == 5;
    }).toList();

    // Fallback: pick any 5-letter word from DB
    if (candidates.isEmpty) {
      final allWords = await _client
          .from('words')
          .select('word_id, name_en, name_tr');
      candidates = (allWords as List).where((w) {
        final en = (w['name_en'] as String?) ?? '';
        return en.length == 5;
      }).toList();
    }

    if (candidates.isEmpty) return null;

    final random = Random();
    final chosen = candidates[random.nextInt(candidates.length)];
    return {
      'word_id': chosen['word_id'],
      'name_en': (chosen['name_en'] as String).toUpperCase(),
      'name_tr': chosen['name_tr'] as String,
    };
  }

  /// Validate a guess against the target word
  /// Returns list of LetterStatus for each position
  static List<LetterStatus> validateGuess(String guess, String target) {
    final result = List<LetterStatus>.filled(5, LetterStatus.absent);
    final targetChars = target.toUpperCase().split('');
    final guessChars = guess.toUpperCase().split('');
    final used = List<bool>.filled(5, false);

    // First pass: mark correct positions
    for (int i = 0; i < 5; i++) {
      if (guessChars[i] == targetChars[i]) {
        result[i] = LetterStatus.correct;
        used[i] = true;
      }
    }

    // Second pass: mark present but wrong position
    for (int i = 0; i < 5; i++) {
      if (result[i] == LetterStatus.correct) continue;
      for (int j = 0; j < 5; j++) {
        if (!used[j] && guessChars[i] == targetChars[j]) {
          result[i] = LetterStatus.present;
          used[j] = true;
          break;
        }
      }
    }

    return result;
  }

  /// Check if guess is a valid English word from the DB
  Future<bool> isValidWord(String guess) async {
    final data = await _client
        .from('words')
        .select('word_id')
        .ilike('name_en', guess)
        .maybeSingle();
    return data != null;
  }
}
