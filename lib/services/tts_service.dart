import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService instance = TtsService._internal();
  TtsService._internal();
  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    await _tts.setLanguage('tr-TR');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
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
