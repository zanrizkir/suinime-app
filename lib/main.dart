import 'package:flutter/material.dart';
import 'screen/home_screen.dart';
import 'screen/detail_screen.dart';
import 'screen/player_screen.dart';

void main() {
  runApp(const SuinimeApp());
}

class SuinimeApp extends StatelessWidget {
  const SuinimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Suinime',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
      routes: {
        '/detail': (context) => DetailScreen(),
        '/player': (context) => const PlayerScreen(),
      },
    );
  }
}