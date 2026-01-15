import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryOrange = Color(0xFFE07A5F);
  static const Color darkSlate = Color(0xFF0F172A);
  static const Color lightOrange = Color(0xFFFFAB8F);
  static const Color paleOrange = Color(0xFFFFF0EB);

  static const Color lightBackground = Colors.white;
  static const Color lightSurface = Color(0xFFFAFAFA);
  static const Color lightText = Color(0xFF1A1A1A);

  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkText = Color(0xFFF8FAFC);

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: primaryOrange,
        scaffoldBackgroundColor: lightBackground,
        colorScheme: ColorScheme.light(
          primary: primaryOrange,
          secondary: lightOrange,
          surface: lightSurface,
          background: lightBackground,
          error: Colors.red.shade400,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: lightText,
          onBackground: lightText,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: lightBackground,
          foregroundColor: lightText,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardTheme(
          color: lightSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: lightSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        textTheme: GoogleFonts.outfitTextTheme(
          const TextTheme(
            displayLarge: TextStyle(
              fontSize: 57,
              fontWeight: FontWeight.bold,
              color: lightText,
            ),
            displayMedium: TextStyle(
              fontSize: 45,
              fontWeight: FontWeight.bold,
              color: lightText,
            ),
            displaySmall: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: lightText,
            ),
            headlineLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: lightText,
            ),
            headlineMedium: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: lightText,
            ),
            headlineSmall: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: lightText,
            ),
            titleLarge: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: lightText,
            ),
            titleMedium: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: lightText,
            ),
            titleSmall: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: lightText,
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: lightText,
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: lightText,
            ),
            bodySmall: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: lightText,
            ),
            labelLarge: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: lightText,
            ),
          ),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: primaryOrange,
        scaffoldBackgroundColor: darkBackground,
        colorScheme: ColorScheme.dark(
          primary: primaryOrange,
          secondary: lightOrange,
          surface: darkSurface,
          background: darkBackground,
          error: Colors.red.shade400,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: darkText,
          onBackground: darkText,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: darkBackground,
          foregroundColor: darkText,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardTheme(
          color: darkSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: darkSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        textTheme: GoogleFonts.outfitTextTheme(
          TextTheme(
            displayLarge: const TextStyle(
              fontSize: 57,
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
            displayMedium: const TextStyle(
              fontSize: 45,
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
            displaySmall: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
            headlineLarge: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: darkText,
            ),
            headlineMedium: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: darkText,
            ),
            headlineSmall: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: darkText,
            ),
            titleLarge: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: darkText,
            ),
            titleMedium: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: darkText,
            ),
            titleSmall: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: darkText,
            ),
            bodyLarge: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: darkText,
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: darkText.withValues(alpha: 0.8),
            ),
            bodySmall: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: darkText.withValues(alpha: 0.7),
            ),
            labelLarge: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: darkText,
            ),
          ),
        ),
      );
}
