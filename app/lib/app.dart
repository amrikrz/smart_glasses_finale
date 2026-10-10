import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/blind_mode_screen.dart';

class VisionApp extends StatelessWidget {
  const VisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VisioNav',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const BlindModeScreen(),
    );
  }
}