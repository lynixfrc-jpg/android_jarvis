import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/chat_message.dart';
import '../models/app_settings.dart';
import '../services/gemini_service.dart';
import '../services/speech_service.dart';
import '../services/tts_service.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/jarvis_orb.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<ChatMessage> _messages = [];
  final List<Map<String, dynamic>> _history = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  bool _isListening = false;
  bool _isThinking = false;
  bool _isSpeaking = false;
  String _statusText = 'Hazır';

  @override
  void initState() {
    super.initState();
    _checkApiKey();
    TtsService.instance.setOnComplete(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  Future<void> _checkApiKey() async {
    final has = await AppSettings.hasApiKey();
    if (!has) {
      _addMessage('Merhaba! Ben JARVIS. Başlamak için ayarlardan Gemini API anahtarınızı girin.', false);
    } else {
      _addMessage('Merhaba! Ben JARVIS. Size nasıl yardımcı olabilirim?', false);
    }
  }

  void _addMessage(String text, bool isUser) {
    setState(() => _messages.add(ChatMessage(text: text, isUser: isUser)));
    if (isUser) {
      _history.add({'role': 'user', 'parts': [{'text': text}]});
    } else {
      _history.add({'role': 'model', 'parts': [{'text': text}]});
    }
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _textController.clear();
    _addMessage(text, true);
    setState(() { _isThinking = true; _statusText = 'Düşünüyor...'; });
    final response = await GeminiService.chat(
      userMessage: text,
      history: List.from(_history)..removeLast(),
    );
    setState(() { _isThinking = false; _statusText = 'Hazır'; });
    _addMessage(response, false);
    setState(() => _isSpeaking = true);
    await TtsService.instance.speak(response);
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await SpeechService.instance.stopListening();
      setState(() { _isListening = false; _statusText = 'Hazır'; });
      return;
    }
    final ok = await SpeechService.instance.initialize();
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mikrofon izni gerekli')));
      return;
    }
    setState(() { _isListening = true; _statusText = 'Dinliyorum...'; });
    await SpeechService.instance.startListening(
      onResult: (text) { if (text.isNotEmpty) _sendMessage(text); },
      onDone: () { if (mounted) setState(() { _isListening = false; _statusText = 'Hazır'; }); },
    );
  }

  OrbState get _orbState {
    if (_isListening) return OrbState.listening;
    if (_isThinking) return OrbState.thinking;
    if (_isSpeaking) return OrbState.speaking;
    return OrbState.idle;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050A14),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildOrb(),
            _buildStatus(),
            Expanded(child: _buildChat()),
            _buildInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Text('JARVIS', style: GoogleFonts.orbitron(fontSize: 22, fontWeight: FontWeight.w700, color: const Color(0xFF00D4FF), letterSpacing: 4)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF00D4FF)),
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildOrb() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(onTap: _toggleListening, child: JarvisOrb(state: _orbState)),
    );
  }

  Widget _buildStatus() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(_statusText,
        style: GoogleFonts.rajdhani(fontSize: 13, color: const Color(0xFF00D4FF).withOpacity(0.7), letterSpacing: 2)),
    ).animate(key: ValueKey(_statusText)).fadeIn(duration: 300.ms);
  }

  Widget _buildChat() {
    if (_messages.isEmpty) {
      return Center(child: Text('Konuşmaya başlamak için orb\'a dokunun\nveya mesaj yazın',
        textAlign: TextAlign.center,
        style: GoogleFonts.rajdhani(color: Colors.white24, fontSize: 14, height: 1.6)));
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _messages.length,
      itemBuilder: (_, i) => ChatBubble(message: _messages[i]),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        border: Border(top: BorderSide(color: const Color(0xFF00D4FF).withOpacity(0.2))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Mesaj yazın...',
                hintStyle: GoogleFonts.rajdhani(color: Colors.white30),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide(color: const Color(0xFF00D4FF).withOpacity(0.3))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide(color: const Color(0xFF00D4FF).withOpacity(0.3))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: const BorderSide(color: Color(0xFF00D4FF))),
                filled: true, fillColor: const Color(0xFF050A14),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onSubmitted: _sendMessage,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _toggleListening,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 48, height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isListening ? const Color(0xFF00D4FF) : const Color(0xFF0D1B2A),
                border: Border.all(color: _isListening ? const Color(0xFF00D4FF) : const Color(0xFF00D4FF).withOpacity(0.4), width: 1.5),
              ),
              child: Icon(_isListening ? Icons.mic : Icons.mic_none, color: _isListening ? Colors.black : const Color(0xFF00D4FF), size: 22),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _sendMessage(_textController.text),
            child: Container(
              width: 48, height: 48,
              decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Color(0xFF00D4FF), Color(0xFF0066FF)])),
              child: const Icon(Icons.send_rounded, color: Colors.black, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
