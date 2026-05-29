import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'splash_screen.dart';

void main() {
  runApp(const SudanRx());
}

class SudanRx extends StatelessWidget {
  const SudanRx({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SudanRx',
      theme: AppTheme.classic,
      home: const SplashScreen(),
    );
  }
}
