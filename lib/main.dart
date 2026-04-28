import 'package:flutter/material.dart';
import 'views/login.dart';

void main() {
  runApp(const AvesCLApp());
}

class AvesCLApp extends StatelessWidget {
  const AvesCLApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AvesCL',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4E8F63),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F8F2),
      ),
      home: const LoginView(),
    );
  }
}