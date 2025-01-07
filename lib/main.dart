import 'package:flutter/material.dart';

import 'package:sd_client_android/pages/stable_diffusion_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stable Diffusion Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const StableDiffusionPage(),
    );
  }
}
