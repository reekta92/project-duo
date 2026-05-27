import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/word.dart';
import '../models/word_sample.dart';

class WordService {
  static final _client = Supabase.instance.client;

  // ── Words ──────────────────────────────────────────────────────────

  Future<Word> getWord(int wordId) async {
    final data = await _client
        .from('words')
        .select()
        .eq('word_id', wordId)
        .single();
    return Word.fromJson(data);
  }

  Future<List<Word>> getWords({int limit = 20, int offset = 0}) async {
    final data = await _client
        .from('words')
        .select()
        .range(offset, offset + limit - 1);
    return data.map<Word>(Word.fromJson).toList();
  }

  Future<List<Word>> searchWords(String query) async {
    final data = await _client
        .from('words')
        .select()
        .or(
          'name_en.ilike.%$query%,name_tr.ilike.%$query%',
        )
        .limit(50);
    return data.map<Word>(Word.fromJson).toList();
  }

  Future<void> addWord(Word word) async {
    await _client.from('words').insert(word.toJson());
  }

  Future<void> updateWord(Word word) async {
    await _client
        .from('words')
        .update(word.toJson())
        .eq('word_id', word.wordId!);
  }

  Future<void> deleteWord(int wordId) async {
    await _client
        .from('words')
        .delete()
        .eq('word_id', wordId);
  }

  // ── Samples ────────────────────────────────────────────────────────

  Future<List<WordSample>> getSamples(int wordId) async {
    final data = await _client
        .from('word_samples')
        .select()
        .eq('word_id', wordId)
        .order('created_at', ascending: false);
    return data.map<WordSample>(WordSample.fromJson).toList();
  }

  Future<void> addSample(WordSample sample) async {
    await _client.from('word_samples').insert(sample.toJson());
  }

  Future<void> deleteSample(int sampleId) async {
    await _client
        .from('word_samples')
        .delete()
        .eq('word_sample_id', sampleId);
  }
}
