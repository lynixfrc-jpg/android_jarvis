import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  static const _keyApiKey = 'gemini_api_key';
  static const _keyUserName = 'user_name';
  static const _keyCity = 'city';

  static Future<String> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyApiKey) ?? '';
  }
  static Future<void> setApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyApiKey, key);
  }
  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName) ?? 'Kullanıcı';
  }
  static Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserName, name);
  }
  static Future<String> getCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCity) ?? 'Istanbul';
  }
  static Future<void> setCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCity, city);
  }
  static Future<bool> hasApiKey() async {
    final key = await getApiKey();
    return key.trim().isNotEmpty;
  }
}
