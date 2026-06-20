import 'package:flutter/material.dart';

/// Identidade visual do app de viagens (azul-petróleo + âmbar).
class AppTheme {
  static const Color primaria = Color(0xFF00695C); // teal escuro
  static const Color secundaria = Color(0xFFFFB300); // âmbar
  static const Color fundo = Color(0xFFF4F6F8);
  static const Color texto = Color(0xFF1F2933);
  static const Color cinza = Color(0xFF6B7280);

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: fundo,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaria,
        primary: primaria,
        secondary: secundaria,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaria,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 3,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaria, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaria,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: secundaria,
        foregroundColor: Colors.black,
      ),
    );
  }
}
