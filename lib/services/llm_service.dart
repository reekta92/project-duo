import 'dart:convert';
import 'package:http/http.dart' as http;

class LLMService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';
  String _apiKey;

  LLMService({String apiKey = ''}) : _apiKey = apiKey;

  void setApiKey(String key) => _apiKey = key;

  /// Verilen İngilizce kelimelerden Türkçe hikaye oluşturur
  Future<Map<String, dynamic>> generateWordChain(List<String> words) async {
    if (_apiKey.isEmpty) {
      throw Exception(
          'Gemini API anahtarı ayarlanmamış. Lütfen Ayarlar ekranından API anahtarınızı girin.');
    }

    final story = await _generateStory(words);

    return {
      'story': story,
      'image_url': null,
      'words': words,
    };
  }

  Future<String> _generateStory(List<String> words) async {
    final wordList = words.join(', ');
    final prompt = '''
Aşağıdaki İngilizce kelimeleri kullanarak kısa, eğlenceli ve akılda kalıcı bir Türkçe hikaye yaz.
Her kelimenin büyük harfli baş harfleri veya sonları hikayede korunmalı (örnek: BraiN gibi).
Kelimeler: $wordList

Kurallar:
- Hikaye maksimum 3-4 cümle olsun
- Her kelime hikayede geçmeli
- Kelimeler BÜYÜK HARFLE vurgulanmalı
- Türkçe yaz ama İngilizce kelimeleri koru
- Akılda kalıcı ve eğlenceli olsun

Sadece hikayeyi yaz, başka açıklama ekleme.
''';

    final response = await http.post(
      Uri.parse('$_baseUrl/gemini-2.0-flash:generateContent?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'system_instruction': {
          'parts': [
            {'text': 'Sen bir dil öğretmenisin. Kelime ezberlemeye yardımcı olacak yaratıcı hikayeler yazarsın.'}
          ]
        },
        'contents': [
          {'parts': [{'text': prompt}]},
        ],
        'generationConfig': {
          'temperature': 0.8,
          'maxOutputTokens': 500,
        },
      }),
    );

    if (response.statusCode == 429) {
      throw Exception('Kota aşıldı. Gemini API ücretsiz kotası: 60 istek/dakika, 1500 istek/gün. Biraz bekleyip tekrar dene.');
    }
    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      final msg = error['error']?['message'] ?? 'Bilinmeyen hata';
      final status = response.statusCode;
      if (status == 400 && msg.contains('API_KEY')) {
        throw Exception('Geçersiz API anahtarı. Google AI Studio\'dan (aistudio.google.com/apikey) AIza... ile başlayan anahtar al.');
      }
      throw Exception('Gemini Hatası ($status): $msg');
    }

    final text = _extractTextFromResponse(response.bodyBytes);
    return text.isEmpty ? 'Hikaye oluşturulamadı.' : text;
  }

  /// Kelime için örnek cümle üret
  Future<List<String>> generateExampleSentences(String word,
      {int count = 3}) async {
    if (_apiKey.isEmpty) {
      throw Exception('API anahtarı gerekli');
    }

    final prompt = '''
"$word" İngilizce kelimesi için $count farklı örnek cümle yaz.
- Cümleler A2-B1 seviyesinde olsun
- Kelimeyi cümlede BÜYÜK HARFLE yaz
- Her cümle farklı bir bağlamda olsun
- Sadece cümleleri listele, numara veya açıklama ekleme
- Her cümle yeni satırda olsun
''';

    final response = await http.post(
      Uri.parse('$_baseUrl/gemini-2.0-flash:generateContent?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {'role': 'user', 'parts': [{'text': prompt}]},
        ],
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 200,
        },
      }),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      final msg = error['error']?['message'] ?? 'Bilinmeyen hata';
      throw Exception('Gemini Hatası: $msg');
    }

    final content = _extractTextFromResponse(response.bodyBytes);
    return content
        .split('\n')
        .where((s) => s.trim().isNotEmpty)
        .take(count)
        .toList();
  }

  /// Gemini API yanıtından metin çıkarır
  String _extractTextFromResponse(List<int> bodyBytes) {
    try {
      final Map<String, dynamic> data =
          jsonDecode(utf8.decode(bodyBytes)) as Map<String, dynamic>;

      final candidates = data['candidates'];
      if (candidates is! List || candidates.isEmpty) return '';

      final first = candidates[0];
      if (first is! Map) return '';

      final content = first['content'];
      if (content is! Map) return '';

      final parts = content['parts'];
      if (parts is! List || parts.isEmpty) return '';

      final firstPart = parts[0];
      if (firstPart is! Map) return '';

      final text = firstPart['text'];
      return (text as String?)?.trim() ?? '';
    } catch (_) {
      return '';
    }
  }
}
