import 'dart:convert';
import 'dart:io';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sd_client_android/pages/help_page.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:sd_client_android/models/image_generation_config_model.dart';
import 'package:sd_client_android/models/resolution_model.dart';
import 'package:sd_client_android/pages/settings_page.dart';
import 'package:sd_client_android/services/setting_service.dart';

class StableDiffusionPage extends StatefulWidget {
  const StableDiffusionPage({Key? key}) : super(key: key);

  @override
  State<StableDiffusionPage> createState() => _StableDiffusionPageState();
}

class _StableDiffusionPageState extends State<StableDiffusionPage> {
  Resolution _selectedResolution = ImageGenerationSettings.resolutions[0];
  int _steps = ImageGenerationSettings.defaultSteps;
  final TextEditingController _promptController = TextEditingController();
  final SettingsService _settingsService = SettingsService();
  String? _generatedImageBase64;
  bool _isLoading = false;

  Future<void> _shareImage() async {
    if (_generatedImageBase64 == null) return;

    final directory = await getTemporaryDirectory();
    final fileName =
        'shared_image_${DateTime.now().millisecondsSinceEpoch}.png';
    final filePath = '${directory.path}/$fileName';

    final imageBytes = base64Decode(_generatedImageBase64!);
    final file = File(filePath);
    await file.writeAsBytes(imageBytes);

    final xFile = XFile(filePath);
    await Share.shareXFiles(
      [xFile],
      text: '生成された画像をシェアします',
    );
  }

  Future<void> _saveImage() async {
    if (_generatedImageBase64 == null) return;

    try {
      // 保存前にパーミッション確認
      if (!await Gal.hasAccess()) {
        await Gal.requestAccess();
      }

      final fileName =
          'generated_image_${DateTime.now().millisecondsSinceEpoch}.png';
      final imageBytes = base64Decode(_generatedImageBase64!);
      // 一時ファイルとして保存
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(imageBytes);
      // ギャラリーに保存
      await Gal.putImage(tempFile.path, album: 'StableDiffusionOutput');
      // 一時ファイルを削除
      await tempFile.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('画像を保存しました')),
      );
    } on GalException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('画像の保存に失敗しました: $e')),
      );
    }
  }

  Future<void> _generateImage() async {
    final endpoint = await _settingsService.getServerUrl();
    final username = await _settingsService.getUsername();
    final password = await _settingsService.getPassword();
    final auth =
        'Basic ' + base64Encode(utf8.encode('${username}:${password}'));

    if (endpoint.isEmpty || username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: const Text('右上のアイコンから接続先を設定してください')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('${endpoint}/sdapi/v1/txt2img'),
        headers: {
          'Content-Type': 'application/json',
          if (username.isNotEmpty) 'Authorization': auth,
        },
        body: jsonEncode({
          'prompt': _promptController.text,
          'width': _selectedResolution.width,
          'height': _selectedResolution.height,
          'steps': _steps,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _generatedImageBase64 = data['images'][0];
        });
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stable Diffusion Client'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HelpPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _promptController,
              decoration: const InputDecoration(
                labelText: 'プロンプトを入力...',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<Resolution>(
              value: _selectedResolution,
              decoration: const InputDecoration(
                labelText: '解像度',
                border: OutlineInputBorder(),
              ),
              items: ImageGenerationSettings.resolutions.map((resolution) {
                return DropdownMenuItem(
                  value: resolution,
                  child: Text(resolution.toString()),
                );
              }).toList(),
              onChanged: (Resolution? value) {
                if (value != null) {
                  setState(() => _selectedResolution = value);
                }
              },
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ステップ数: $_steps'),
                Slider(
                  value: _steps.toDouble(),
                  min: ImageGenerationSettings.minSteps.toDouble(),
                  max: ImageGenerationSettings.maxSteps.toDouble(),
                  divisions: ImageGenerationSettings.maxSteps -
                      ImageGenerationSettings.minSteps,
                  label: _steps.toString(),
                  onChanged: (double value) {
                    setState(() => _steps = value.round());
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _generateImage,
              child: Text(_isLoading ? '生成中...' : '生成する'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _generatedImageBase64 != null
                      ? Image.memory(
                          base64Decode(_generatedImageBase64!),
                          fit: BoxFit.contain,
                        )
                      : const SizedBox(height: 1),
            ),
            if (_generatedImageBase64 != null) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _saveImage,
                    icon: const Icon(Icons.save),
                    label: const Text('保存'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _shareImage,
                    icon: const Icon(Icons.share),
                    label: const Text('シェア'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }
}
