import 'package:flutter/material.dart';

/// App Theme Configuration with Material 3 Design
/// Updated to match Figma design specifications
class AppTheme {
  AppTheme._();

  // Primary Colors - Dark Teal Green (consistent across themes)
  static const Color _primaryLight = Color(0xFF0D4A3E);
  static const Color _primaryDark =
      Color(0xFF14A085); // Teal for dark theme (avoiding purple)

  // Secondary Colors
  static const Color _secondaryLight = Color(0xFF10B981);
  static const Color _secondaryDark = Color(0xFF34D399);

  // Background Colors
  static const Color _backgroundLight = Color(0xFFF5F5F5);
  static const Color _backgroundDark = Color(0xFF0F0F1E);

  // Surface Colors
  static const Color _surfaceLight = Color(0xFFFFFFFF);
  static const Color _surfaceDark = Color(0xFF1A1A2E);

  // Card Colors
  static const Color _cardLight = Color(0xFFFFFFFF);
  static const Color _cardDark = Color(0xFF252538);

  // Text Colors
  static const Color _textPrimaryLight = Color(0xFF1F2937);
  static const Color _textPrimaryDark = Color(0xFFFFFFFF);
  static const Color _textSecondaryLight = Color(0xFF6B7280);
  static const Color _textSecondaryDark = Color(0xFF9CA3AF);

  // Status Colors
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Income/Expense Colors
  static const Color income = Color(0xFF22C55E);
  static const Color expense = Color(0xFFEF4444);

  // Gradient Colors - Primary Teal Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0D4A3E), Color(0xFF166555)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Teal Gradient for dark theme FAB (replacing purple)
  static const LinearGradient tealGradient = LinearGradient(
    colors: [Color(0xFF0D6B5E), Color(0xFF14A085)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient incomeGradient = LinearGradient(
    colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient expenseGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  // Spacing
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: _primaryLight,
        secondary: _secondaryLight,
        surface: _surfaceLight,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: _textPrimaryLight,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: _backgroundLight,
      cardColor: _cardLight,
      dividerColor: Colors.grey.shade200,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: _backgroundLight,
        foregroundColor: _textPrimaryLight,
        titleTextStyle: _textTheme.titleLarge?.copyWith(
          color: _textPrimaryLight,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
        color: _cardLight,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLarge,
            vertical: spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          backgroundColor: _primaryLight,
          foregroundColor: Colors.white,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLarge,
            vertical: spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          side: const BorderSide(color: _primaryLight),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: spacingMedium,
            vertical: spacingSmall,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: _primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMedium,
          vertical: spacingMedium,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _primaryLight,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _surfaceLight,
        selectedItemColor: _primaryLight,
        unselectedItemColor: _textSecondaryLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey.shade100,
        selectedColor: _primaryLight,
        labelStyle: _textTheme.bodySmall?.copyWith(color: _textPrimaryLight),
        secondaryLabelStyle:
            _textTheme.bodySmall?.copyWith(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      textTheme: _textTheme,
      iconTheme: const IconThemeData(color: _textPrimaryLight),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: _primaryDark,
        secondary: _secondaryDark,
        surface: _surfaceDark,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: _textPrimaryDark,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: _backgroundDark,
      cardColor: _cardDark,
      dividerColor: Colors.grey.shade800,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: _backgroundDark,
        foregroundColor: _textPrimaryDark,
        titleTextStyle: _textTheme.titleLarge?.copyWith(
          color: _textPrimaryDark,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
        color: _cardDark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLarge,
            vertical: spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          backgroundColor: _primaryDark,
          foregroundColor: Colors.white,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLarge,
            vertical: spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          side: const BorderSide(color: _primaryDark),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: spacingMedium,
            vertical: spacingSmall,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade900,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: _primaryDark, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMedium,
          vertical: spacingMedium,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _primaryDark,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _surfaceDark,
        selectedItemColor: _primaryDark,
        unselectedItemColor: _textSecondaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey.shade800,
        selectedColor: _primaryDark,
        labelStyle: _textTheme.bodySmall?.copyWith(color: _textPrimaryDark),
        secondaryLabelStyle:
            _textTheme.bodySmall?.copyWith(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
        side: BorderSide(color: Colors.grey.shade700),
      ),
      textTheme: _textTheme.apply(
        bodyColor: _textPrimaryDark,
        displayColor: _textPrimaryDark,
      ),
      iconTheme: const IconThemeData(color: _textPrimaryDark),
    );
  }

  // Text Theme
  static TextTheme get _textTheme {
    return const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
        fontFamily: 'Poppins',
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
        fontFamily: 'Poppins',
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
      ),
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        fontFamily: 'Poppins',
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontFamily: 'Poppins',
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        fontFamily: 'Poppins',
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        fontFamily: 'Poppins',
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        fontFamily: 'Poppins',
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontFamily: 'Poppins',
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        fontFamily: 'Poppins',
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        fontFamily: 'Poppins',
      ),
    );
  }

  // Card Shadow
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];
}

/// Extension for theme access
extension ThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
