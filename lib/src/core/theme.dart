import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Colors
const Color kPrimary = Color(0xFF0FA3B1);   // teal
const Color kAccent  = Color(0xFFFF8A00);   // orange
const Color kSuccess = Color(0xFF2E7D32);   // green
const Color kDanger  = Color(0xFFD32F2F);
const Color kSurface = Color(0xFFF6F7F8);
const Color kTextPrimary = Color(0xFF111827);
const Color kMuted = Color(0xFF6B7280);

// Spacing
const double spacingXs = 4.0;
const double spacingSm = 8.0;
const double spacing = 16.0;
const double spacingLg = 24.0;

final appTheme = ThemeData(
  primaryColor: kPrimary,
  colorScheme: ColorScheme.fromSeed(
    seedColor: kPrimary,
    primary: kPrimary,
    secondary: kAccent,
    surface: kSurface,
    error: kDanger,
  ),
  scaffoldBackgroundColor: kSurface,
  textTheme: GoogleFonts.poppinsTextTheme(
    const TextTheme(
      displayLarge: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w500),
      displayMedium: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w500),
      displaySmall: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w500),
      headlineLarge: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w500),
      headlineMedium: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w500),
      headlineSmall: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w500),
      titleLarge: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w500),
      titleMedium: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w500),
      titleSmall: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w400),
      bodyMedium: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w400),
      bodySmall: TextStyle(color: kMuted, fontWeight: FontWeight.w400),
      labelLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      labelMedium: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w400),
      labelSmall: TextStyle(color: kMuted, fontWeight: FontWeight.w400),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kPrimary,
      foregroundColor: Colors.white,
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: kSurface,
    elevation: 0,
    iconTheme: IconThemeData(color: kTextPrimary),
    titleTextStyle: TextStyle(
      color: kTextPrimary,
      fontSize: 18,
      fontWeight: FontWeight.w500,
    ),
  ),
);
