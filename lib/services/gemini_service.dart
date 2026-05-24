import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/app_settings.dart';
import 'memory_service.dart';

class GeminiService {
  static const _model = 'deepseek-r1-distill-llama-70b';
  static const _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';

  static String _buildSystemPrompt(String memoryStr, String userName, String city) {
    final now = DateTime.now();
    return '''Sen JARVIS\'sin — Android\'de çalışan kişisel AI asistanı.

[ŞU ANKİ ZAMAN]
${now.day}.${now.month}.${now.year} — ${now.hour}:${now.minute.toString().padLeft(2,'0')}

[KULLANICI]
İsim: $userName
Şehir: $city

$memoryStr

KURALLAR:
- Türkçe konuş
- Kısa, net ve etkili ol
- Kullanıcı hakkında önemli bilgi duyarsan [HAFIZA_KAYDET:kategori/anahtar=değer] formatında belirt
- Kullanıcı hafıza silmek isterse [HAFIZA_SİL:kategori/anahtar] formatında belirt
''';
  }

  static Future<String> chat({required String userMessage, required List<Map<String, dynamic>> history}) async {
    final apiKey = await AppSettings.getApiKey();
    if (apiKey.isEmpty) return 'API anahtarı ayarlanmamış. Lütfen ayarlardan Groq API anahtarını girin.';

    final userName = await AppSettings.getUserName();
    final city = await AppSettings.getCity();
    final memStr = await MemoryService.formatForPrompt();
    final systemPrompt = _buildSystemPrompt(memStr, userName, city);

    final messages = <Map<String, dynamic>>[
      {'role': 'system', 'content': systemPrompt},
    ];

    for (final msg in history) {
      final role = msg['role'] == 'model' ? 'assistant' : msg['role'];
      final content = msg['parts']?[0]?['text'] ?? '';
      messages.add({'role': role, 'content': content});
    }
    messages.add({'role': 'user', 'content': userMessage});

    final body = json.encode({
      'model': _model,
      'messages': messages,
      'temperature': 0.7,
      'max_tokens': 1024,
    });

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: body,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final text = data['choices']?[0]?['message']?['content'] ?? '';
        await _processMemoryCommands(text);
        return _cleanResponse(text);
      } else {
        final error = json.decode(response.body);
        return 'Hata: ${error['error']?['message'] ?? response.statusCode}';
      }
    } catch (e) {
      return 'Bağlantı hatası: $e';
    }
  }

  static Future<void> _processMemoryCommands(String text) async {
    final saveRegex = RegExp(r'\[HAFIZA_KAYDET:(\w+)/(\w+)=(.+?)\]');
    for (final match in saveRegex.allMatches(text)) {
      await MemoryService.update(match.group(1)!, match.group(2)!, match.group(3)!);
    }
    final deleteRegex = RegExp(r'\[HAFIZA_SİL:(\w+)/(\w+)\]');
    for (final match in deleteRegex.allMatches(text)) {
      await MemoryService.delete(match.group(1)!, match.group(2)!, '');
    }
  }

  static String _cleanResponse(String text) {
    return text
        .replaceAll(RegExp(r'\[HAFIZA_KAYDET:[^\]]+\]'), '')
        .replaceAll(RegExp(r'\[HAFIZA_SİL:[^\]]+\]'), '')
        .replaceAll(RegExp(r'<think>.*?</think>', dotAll: true), '')
        .trim();
  }
}
