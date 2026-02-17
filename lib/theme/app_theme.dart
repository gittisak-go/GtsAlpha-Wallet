import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// UI Theme based on the provided reference image (Mint Green & Dark Gray)
class AppTheme {
  AppTheme._();

  // Core colors from the reference image
  static const Color background = Color(0xFF1A1C1E);
  static const Color surface = Color(0xFF2D3135);
  static const Color primaryMint = Color(0xFF34A87F);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF9BA1A6);
  
  // Grid Item Colors (Estimated from image)
  static const Color gridBlue = Color(0xFF2D364D);
  static const Color gridGreen = Color(0xFF1E3D2F);
  static const Color gridBrown = Color(0xFF3D382E);
  static const Color gridRed = Color(0xFF4D2D31);
  static const Color gridOrange = Color(0xFF4D382D);
  static const Color gridTeal = Color(0xFF1E3D3D);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primaryMint,
        surface: surface,
        onSurface: textPrimary,
        secondary: primaryMint,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textPrimary,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textSecondary,
        ),
      ),
    );
  }
}
