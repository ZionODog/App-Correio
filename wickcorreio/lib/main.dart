// lib/main.dart

import 'package:flutter/material.dart';
import 'package:wickcorreio/screens/login_screen.dart';

// --- DEFININDO AS CORES ---
const Color wickRed = Color(0xFFDE3131);
const Color wickGold = Color(0xFFD18C30);
const Color wickWhite = Colors.white;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WickCorreio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: wickRed,
        scaffoldBackgroundColor: wickWhite,

        // Define o esquema de cores principal
        colorScheme: ColorScheme.fromSeed(
          seedColor: wickRed,
          primary: wickRed,
          secondary: wickGold,
        ),

        // Define o estilo dos botões
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: wickRed,
            foregroundColor: wickWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        // Define a aparência dos campos de texto
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: wickGold, width: 2.0),
          ),
          border: OutlineInputBorder(),
        ),

        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
