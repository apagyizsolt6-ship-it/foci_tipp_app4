import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const FociTippApp());
}

class FociTippApp extends StatelessWidget {
  const FociTippApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foci Tipp - Elemzo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF1E8E3E),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}
