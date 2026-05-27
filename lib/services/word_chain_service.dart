import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/word_chain.dart';

class WordChainService {
  static final _client = Supabase.instance.client;

  Future<void> saveWordChain(WordChain chain) async {
    await _client.from('word_chains').insert(chain.toJson());
  }

  Future<List<WordChain>> getWordChains(String userId) async {
    final data = await _client
        .from('word_chains')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (data as List).map<WordChain>((d) => WordChain.fromJson(d)).toList();
  }

  Future<void> deleteWordChain(int id) async {
    await _client.from('word_chains').delete().eq('id', id);
  }
}
