import 'dart:convert';
import 'package:http/http.dart' as http;

class LLMService {
  static const String _textUrl = 'https://text.pollinations.ai/';
  static const String _imageUrl = 'https://image.pollinations.ai/prompt/';

  // Geriye dönük uyumluluk için, artık kullanılmayacak
  LLMService({String apiKey = ''});
  void setApiKey(String key) {} 

  /// Verilen İngilizce kelimelerden Türkçe hikaye oluşturur ve görsel için prompt üretir
  Future<Map<String, dynamic>> generateWordChain(List<String> words) async {
    // 1. Hikayeyi ve görsel promptunu tek bir istekle oluştur (Tamamen Ücretsiz API)
    final result = await _generateStoryAndPrompt(words);
    final story = result['story']!;
    final imagePrompt = result['image_prompt']!;

    // 2. Pollinations AI ile görsel URL'si oluştur
    final encodedPrompt = Uri.encodeComponent(imagePrompt);
    final imageUrl = '$_imageUrl$encodedPrompt?width=1024&height=1024&nologo=true';

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

    try {
      final response = await http.post(
        Uri.parse(_textUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'messages': [
            {'role': 'system', 'content': 'Sen yaratıcı bir yazarsın. İstikrarlı formatlarda yanıt verirsin.'},
            {'role': 'user', 'content': prompt}
          ]
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('API Hatası (${response.statusCode})');
      }

      final text = response.body; // Pollinations API direkt metin döner
      
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
    } catch (e) {
      throw Exception('Bağlantı Hatası: Lütfen internetinizi kontrol edin. Detay: $e');
    }
  }

  /// Kelime için örnek cümle üret
  Future<List<String>> generateExampleSentences(String word, {int count = 3}) async {
    final prompt = '''
"$word" İngilizce kelimesi için $count farklı örnek cümle yaz.
- Cümleler A2-B1 seviyesinde olsun
- Kelimeyi cümlede BÜYÜK HARFLE yaz
- Her cümle farklı bir bağlamda olsun
- Sadece cümleleri listele, numara veya açıklama ekleme
- Her cümle yeni satırda olsun
''';

    try {
      final response = await http.post(
        Uri.parse(_textUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'messages': [
            {'role': 'user', 'content': prompt}
          ]
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('API Hatası: ${response.statusCode}');
      }

      final content = response.body;
      return content
          .split('\\n')
          .where((s) => s.trim().isNotEmpty)
          .take(count)
          .toList();
    } catch (e) {
      throw Exception('Bağlantı Hatası: $e');
    }
  }
}
