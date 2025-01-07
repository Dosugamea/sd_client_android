import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _serverUrlKey = 'server_url';
  static const String _usernameKey = 'username';
  static const String _passwordKey = 'password';

  Future<void> saveServerUrl(String url) async {
    final prefs = await SharedPreferencesAsync();
    await prefs.setString(_serverUrlKey, url);
  }

  Future<String> getServerUrl() async {
    final prefs = await SharedPreferencesAsync();
    final serverUrl = await prefs.getString(_serverUrlKey);
    return serverUrl ?? 'http://127.0.0.1:7860';
  }

  Future<String> getUsername() async {
    final prefs = await SharedPreferencesAsync();
    final username = await prefs.getString(_usernameKey);
    return username ?? '';
  }

  Future<void> saveUsername(String username) async {
    final prefs = await SharedPreferencesAsync();
    await prefs.setString(_usernameKey, username);
  }

  Future<String> getPassword() async {
    final prefs = await SharedPreferencesAsync();
    final password = await prefs.getString(_passwordKey);
    return password ?? '';
  }

  Future<void> savePassword(String password) async {
    final prefs = await SharedPreferencesAsync();
    await prefs.setString(_passwordKey, password);
  }
}
