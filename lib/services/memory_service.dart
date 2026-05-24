import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MemoryService {
  static const _key = 'jarvis_memory';

  static Future<Map<String, dynamic>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return {};
    try { return json.decode(raw) as Map<String, dynamic>; }
    catch (_) { return {}; }
  }

  static Future<void> save(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, json.encode(data));
  }

  static Future<void> update(String category, String key, String value) async {
    final mem = await load();
    if (mem[category] == null) mem[category] = {};
    (mem[category] as Map)[key] = {'value': value};
    await save(mem);
  }

  static Future<String> delete(String category, String key, String matchText) async {
    final mem = await load();
    if (category.isNotEmpty && key.isNotEmpty) {
      final bucket = mem[category];
      if (bucket is Map && bucket.containsKey(key)) {
        bucket.remove(key);
        if (bucket.isEmpty) mem.remove(category);
        await save(mem);
        return '$category/$key hafızadan kaldırıldı.';
      }
      return 'Bu hafıza kaydını bulamadım.';
    }
    return 'Silmek için category/key gerekli.';
  }

  static Future<String> formatForPrompt() async {
    final mem = await load();
    if (mem.isEmpty) return '';
    final lines = ['[KULLANICI HAKKINDA BİLGİLER]'];
    mem.forEach((category, items) {
      if (items is Map) {
        items.forEach((k, v) {
          final val = v is Map ? v['value'] ?? v.toString() : v.toString();
          lines.add('  $category/$k: $val');
        });
      }
    });
    return lines.join('\n');
  }
}
