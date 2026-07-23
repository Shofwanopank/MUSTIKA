import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BakeryTheme {
  // Theme Colors - Warm Hearth Modern
  static const Color primary = Color(0xFF7D562D);
  static const Color primaryContainer = Color(0xFFD4A373);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF5B3912);

  static const Color secondary = Color(0xFF795744);
  static const Color secondaryContainer = Color(0xFFFED1B9);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF795845);

  static const Color tertiary = Color(0xFF924C00);
  static const Color tertiaryContainer = Color(0xFFF1974D);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFF663300);

  static const Color background = Color(0xFFFDF9F4);
  static const Color surface = Color(0xFFFDF9F4);
  static const Color surfaceContainerLow = Color(0xFFF7F3EE);
  static const Color surfaceContainer = Color(0xFFF1EDE8);
  static const Color surfaceContainerHigh = Color(0xFFEBE8E3);
  static const Color surfaceContainerHighest = Color(0xFFE6E2DD);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceBright = Color(0xFFFDF9F4);
  static const Color surfaceDim = Color(0xFFDDD9D5);

  static const Color onBackground = Color(0xFF1C1C19);
  static const Color onSurface = Color(0xFF1C1C19);
  static const Color onSurfaceVariant = Color(0xFF50453B);
  static const Color outline = Color(0xFF82756A);
  static const Color outlineVariant = Color(0xFFD4C4B7);

  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  static const Color success = Color(0xFF388E3C);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color successContainer = Color(0xFFC8E6C9);
  static const Color onSuccessContainer = Color(0xFF1B5E20);

  // Fixed colors
  static const Color primaryFixed = Color(0xFFFFDCBD);
  static const Color primaryFixedDim = Color(0xFFF0BD8B);
  static const Color onPrimaryFixed = Color(0xFF2C1600);
  static const Color onPrimaryFixedVariant = Color(0xFF623F18);
  static const Color secondaryFixed = Color(0xFFFFDBC9);
  static const Color secondaryFixedDim = Color(0xFFE9BDA6);
  static const Color onSecondaryFixed = Color(0xFF2D1607);
  static const Color onSecondaryFixedVariant = Color(0xFF5E402E);
  static const Color tertiaryFixed = Color(0xFFFFDCC4);
  static const Color tertiaryFixedDim = Color(0xFFFFB781);
  static const Color onTertiaryFixed = Color(0xFF2F1400);
  static const Color onTertiaryFixedVariant = Color(0xFF6F3800);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondary,
        onSecondary: onSecondary,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        tertiary: tertiary,
        onTertiary: onTertiary,
        tertiaryContainer: tertiaryContainer,
        onTertiaryContainer: onTertiaryContainer,
        error: error,
        onError: onError,
        errorContainer: errorContainer,
        onErrorContainer: onErrorContainer,
        background: background,
        onBackground: onBackground,
        surface: surface,
        onSurface: onSurface,
        surfaceVariant: surfaceContainer,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
      ),
      scaffoldBackgroundColor: background,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.02,
          color: onSurface,
        ),
        headlineLarge: GoogleFonts.plusJakartaSans(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        bodyLarge: GoogleFonts.workSans(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: onSurface,
        ),
        bodyMedium: GoogleFonts.workSans(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: onSurface,
        ),
        labelLarge: GoogleFonts.workSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.05,
          color: onSurface,
        ),
        labelSmall: GoogleFonts.workSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: onSurfaceVariant,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0x1A432818), width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error),
        ),
        labelStyle: GoogleFonts.workSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: secondary,
        ),
        hintStyle: GoogleFonts.workSans(
          color: outline,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButtonStyleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButtonFrom(
          foregroundColor: secondary,
          side: const BorderSide(color: outlineVariant),
          textStyle: GoogleFonts.workSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }

  // Helper styles for standard buttons
  static ButtonStyle ElevatedButtonStyleFrom({
    required Color backgroundColor,
    required Color foregroundColor,
    required TextStyle textStyle,
    required EdgeInsets padding,
    required OutlinedBorder shape,
    required double elevation,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      textStyle: textStyle,
      padding: padding,
      shape: shape,
      elevation: elevation,
    );
  }

  static ButtonStyle OutlinedButtonFrom({
    required Color foregroundColor,
    required BorderSide side,
    required TextStyle textStyle,
    required EdgeInsets padding,
    required OutlinedBorder shape,
  }) {
    return OutlinedButton.styleFrom(
      foregroundColor: foregroundColor,
      side: side,
      textStyle: textStyle,
      padding: padding,
      shape: shape,
    );
  }
}
