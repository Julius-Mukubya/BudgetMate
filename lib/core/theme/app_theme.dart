import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    surface: Color(0xFF0F1117),
    surfaceContainerHigh: Color(0xFF1C1F2A),
    onSurface: Color(0xFFF0F2F5),
    onSurfaceVariant: Color(0xFF8A8FA8),
    primary: Color(0xFF4ADE80),
    onPrimary: Color(0xFF022C16),
    error: Color(0xFFF87171),
    tertiary: Color(0xFF4ADE80),
    secondary: Color(0xFFFBBF24),
    outlineVariant: Color(0xFF2A2D3A),
  ),
  textTheme: GoogleFonts.interTextTheme(
    ThemeData.dark().textTheme,
  ).copyWith(
    titleLarge: GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: const Color(0xFFF0F2F5),
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: const Color(0xFFF0F2F5),
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: const Color(0xFFF0F2F5),
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: const Color(0xFF8A8FA8),
    ),
  ),
);