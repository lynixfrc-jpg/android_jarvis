import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService instance = TtsService._internal();
  TtsService._internal();
  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    await _tts.setLanguage('tr-TR');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(0.88);
    
    final voices = await _tts.getVoices;
    if (voices != null) {
      final voiceList = List<Map>.from(voices);
      Map? turkishMale = voiceList.firstWhere(
        (v) => v['locale']?.toString().startsWith('tr') == true && 
               v['name']?.toString().toLowerCase().contains('male') == true,
        orElse: () => {},
      );
      if (turkishMale == null || turkishMale.isEmpty) {
        turkishMale = voiceList.firstWhere(
          (v) => v['locale']?.toString().startsWith('tr') == true,
          orElse: () => {},
        );
      }
      if (turkishMale != null && turkishMale.isNotEmpty) {
        await _tts.setVoice({'name': turkishMale['name'], 'locale': turkishMale['locale']});
      }
    }
    _initialized = true;
  }

  Future<void> speak(String text) async {
    if (!_initialized) await initialize();
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() async => await _tts.stop();
  void setOnComplete(Function() callback) => _tts.setCompletionHandler(callback);
}
