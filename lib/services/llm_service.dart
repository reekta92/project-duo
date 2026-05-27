import 'dart:convert';
import 'package:http/http.dart' as http;

class LLMService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';
  String _apiKey;

  LLMService({String apiKey = ''}) : _apiKey = apiKey;

  void setApiKey(String key) => _apiKey = key;

  /// Verilen İngilizce kelimelerden Türkçe hikaye oluşturur ve görsel için prompt üretir
  Future<Map<String, dynamic>> generateWordChain(List<String> words) async {
    if (_apiKey.isEmpty) {
      throw Exception(
          'Gemini API anahtarı ayarlanmamış. Lütfen Ayarlar ekranından API anahtarınızı girin.');
    }

    // 1. Hikayeyi ve görsel promptunu tek bir istekle oluştur (Kota tasarrufu için)
    final result = await _generateStoryAndPrompt(words);
    final story = result['story']!;
    final imagePrompt = result['image_prompt']!;

    // 2. Pollinations AI ile görsel URL'si oluştur
    final encodedPrompt = Uri.encodeComponent(imagePrompt);
    final imageUrl = 'https://image.pollinations.ai/prompt/$encodedPrompt?width=1024&height=1024&nologo=true';

    return {
      'story': story,
      'image_url': imageUrl,
      'words': words,
    };
  }

  Future<Map<String, String>> _generateStoryAndPrompt(List<String> words) async {
    final wordList = words.join(', ');
    final prompt = '''
Aşağıdaki İngilizce kelimeleri kullanarak kısa, eğlenceli ve akılda kalıcı bir Türkçe hikaye yaz.
Kelimeler: $wordList

Kurallar:
- Hikaye maksimum 3-4 cümle olsun
- Her kelime hikayede geçmeli
- Kelimeler BÜYÜK HARFLE vurgulanmalı
- Türkçe yaz ama İngilizce kelimeleri koru
- Akılda kalıcı ve eğlenceli olsun

Ayrıca, bu hikayeyi temel alarak görsel oluşturmak için kullanılabilecek kısa (maksimum 15 kelime) bir İNGİLİZCE görsel promptu (image prompt) da yaz. Prompt sadece görsel betimleme içermelidir (isim veya metin içermesin).

Lütfen yanıtını AŞAĞIDAKİ GİBİ tam olarak şu formatta ver (başka hiçbir açıklama ekleme):
HİKAYE:
[buraya hikayeyi yaz]

PROMPT:
[buraya ingilizce promptu yaz]
''';

    final response = await http.post(
      Uri.parse('$_baseUrl/gemini-2.0-flash:generateContent?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'system_instruction': {
          'parts': [
            {'text': 'Sen yaratıcı bir yazarsın. İstikrarlı formatlarda yanıt verirsin.'}
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
      throw Exception('Kota aşıldı! Çok hızlı istek attınız. Lütfen 1 dakika bekleyip tekrar deneyin.');
    }
    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      final msg = error['error']?['message'] ?? 'Bilinmeyen hata';
      final status = response.statusCode;
      if (status == 400 && msg.contains('API_KEY')) {
        throw Exception('Geçersiz API anahtarı. Lütfen kontrol edin.');
      }
      throw Exception('Gemini Hatası ($status): $msg');
    }

    final text = _extractTextFromResponse(response.bodyBytes);
    
    // Parse response
    String story = 'Hikaye oluşturulamadı.';
    String imagePrompt = 'a magical story scene with characters in a fantasy world';
    
    if (text.contains('PROMPT:')) {
      final parts = text.split('PROMPT:');
      story = parts[0].replaceAll('HİKAYE:', '').trim();
      if (parts.length > 1) {
        imagePrompt = parts[1].trim();
      }
    } else {
      story = text;
    }

    return {
      'story': story.isEmpty ? 'Hikaye oluşturulamadı.' : story,
      'image_prompt': imagePrompt.isEmpty ? 'a magical story scene' : imagePrompt,
    };
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
