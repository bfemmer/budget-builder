import 'package:flutter/material.dart';

class AppColors {
  // Primary USAF Theme Palette
  static const Color navyDark = Color(0xFF0B192C);
  static const Color navyCard = Color(0xFF1E293B);
  static const Color navySurface = Color(0xFF152033);
  static const Color airForceBlue = Color(0xFF1E3E62);
  static const Color accentBlue = Color(0xFF0066FF);
  static const Color usafGold = Color(0xFFFFB800);
  
  // Status Colors (Matching AFAS Guide)
  static const Color statusGreen = Color(0xFF10B981); // Under 50% limit
  static const Color statusYellow = Color(0xFFF59E0B); // 50% - 79% limit
  static const Color statusRed = Color(0xFFEF4444);    // 80%+ limit

  // Text Colors
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Card & Input Decoration
  static const Color cardBorder = Color(0xFF334155);
  static const Color inputBackground = Color(0xFF0F172A);

  // Classification Tags
  static const Color tagNeed = Color(0xFF3B82F6);
  static const Color tagWant = Color(0xFFEC4899);
  static const Color tagCash = Color(0xFF10B981);
  static const Color tagCredit = Color(0xFF8B5CF6);
}
