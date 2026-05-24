import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  static final SpeechService instance = SpeechService._internal();
  SpeechService._internal();
  final SpeechToText _speech = SpeechToText();
  bool _initialized = false;

  Future<bool> initialize() async {
    if (_initialized) return true;
    _initialized = await _speech.initialize();
    return _initialized;
  }

  bool get isListening => _speech.isListening;

  Future<void> startListening({required Function(String) onResult, required Function() onDone}) async {
    if (!_initialized) await initialize();
    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) { onResult(result.recognizedWords); onDone(); }
      },
      localeId: 'tr_TR',
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
    );
  }

  Future<void> stopListening() async => await _speech.stop();
}
