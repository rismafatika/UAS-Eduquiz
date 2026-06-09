import 'package:flutter/material.dart';

import 'screens/login_page.dart';

class EduQuizApp extends StatelessWidget {
  const EduQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduQuiz',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          secondary: const Color(0xFF14B8A6),
          tertiary: const Color(0xFFF59E0B),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F9FC),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
