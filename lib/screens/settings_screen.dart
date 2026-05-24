import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/app_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _apiKeyController = TextEditingController();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  bool _obscureKey = true;
  bool _saving = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    _apiKeyController.text = await AppSettings.getApiKey();
    _nameController.text = await AppSettings.getUserName();
    _cityController.text = await AppSettings.getCity();
    setState(() {});
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await AppSettings.setApiKey(_apiKeyController.text.trim());
    await AppSettings.setUserName(_nameController.text.trim());
    await AppSettings.setCity(_cityController.text.trim());
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ayarlar kaydedildi'), backgroundColor: Color(0xFF00D4FF)));
      Navigator.pop(context);
    }
  }

  @override
  void dispose() { _apiKeyController.dispose(); _nameController.dispose(); _cityController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050A14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050A14),
        title: Text('AYARLAR', style: GoogleFonts.orbitron(color: const Color(0xFF00D4FF), fontSize: 16, letterSpacing: 3)),
        iconTheme: const IconThemeData(color: Color(0xFF00D4FF)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Gemini API Anahtarı'),
            const SizedBox(height: 8),
            _field(controller: _apiKeyController, hint: 'AIza...', obscure: _obscureKey,
              suffix: IconButton(icon: Icon(_obscureKey ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF00D4FF).withOpacity(0.7)),
                onPressed: () => setState(() => _obscureKey = !_obscureKey))),
            const SizedBox(height: 6),
            Text('aistudio.google.com adresinden ücretsiz alabilirsiniz.',
              style: GoogleFonts.rajdhani(color: Colors.white38, fontSize: 12)),
            const SizedBox(height: 28),
            _label('Adınız'),
            const SizedBox(height: 8),
            _field(controller: _nameController, hint: 'Adınızı girin'),
            const SizedBox(height: 28),
            _label('Şehir'),
            const SizedBox(height: 8),
            _field(controller: _cityController, hint: 'İstanbul'),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D4FF), foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _saving ? const CircularProgressIndicator(color: Colors.black)
                    : Text('KAYDET', style: GoogleFonts.orbitron(fontWeight: FontWeight.w700, letterSpacing: 2)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text, style: GoogleFonts.rajdhani(color: const Color(0xFF00D4FF), fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1.5));

  Widget _field({required TextEditingController controller, required String hint, bool obscure = false, Widget? suffix}) {
    return TextField(
      controller: controller, obscureText: obscure,
      style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint, hintStyle: GoogleFonts.rajdhani(color: Colors.white30),
        suffixIcon: suffix, filled: true, fillColor: const Color(0xFF0D1B2A),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: const Color(0xFF00D4FF).withOpacity(0.3))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: const Color(0xFF00D4FF).withOpacity(0.3))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF00D4FF))),
      ),
    );
  }
}
