import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:sd_client_android/services/setting_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _settingsService = SettingsService();
  final _serverUrlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final serverUrl = await _settingsService.getServerUrl();
    final username = await _settingsService.getUsername();
    final password = await _settingsService.getPassword();
    setState(() {
      _serverUrlController.text = serverUrl;
      _usernameController.text = username;
      _passwordController.text = password;
    });
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
    });

    try {
      final headers = <String, String>{};
      if (_usernameController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty) {
        final basicAuth =
            'Basic ${base64Encode(utf8.encode('${_usernameController.text}:${_passwordController.text}'))}';
        headers['authorization'] = basicAuth;
      }

      final response = await http.get(
        Uri.parse('${_serverUrlController.text}/sdapi/v1/sd-models'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('接続成功!')),
        );
      } else {
        throw Exception('接続に失敗しました: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('接続に失敗しました: $e')),
      );
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    try {
      await _settingsService.saveServerUrl(_serverUrlController.text);
      await _settingsService.saveUsername(_usernameController.text);
      await _settingsService.savePassword(_passwordController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('設定を保存しました')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('設定の保存に失敗しました: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _serverUrlController,
              decoration: const InputDecoration(
                labelText: 'サーバーURL',
                hintText: 'https://example.com',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'ユーザー名',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'パスワード',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isTesting ? null : _testConnection,
                    child: Text(_isTesting ? 'テスト中...' : '接続テスト'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveSettings,
                    child: const Text('設定を保存'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
