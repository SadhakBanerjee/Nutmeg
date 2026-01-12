import 'package:flutter/material.dart';

class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();
  
  // Background colors - dark theme
  static const Color background = Color(0xFF0A0A0A);        // Deep black (richer)
  static const Color cardBackground = Color(0xFF1A1A1A);    // Dark charcoal
  static const Color cardBorder = Color(0xFF2A2A2A);        // Subtle border
  
  // Primary brand colors - MATCHING YOUR LOGO! 🎨
  static const Color primaryYellow = Color(0xFFF5C842);     // Golden yellow from logo
  static const Color primaryYellowDark = Color(0xFFE0B12F); // Darker shade for hover
  static const Color accentBlack = Color(0xFF1A1A1A);       // Logo's black
  static const Color accentOrange = Color(0xFFFF9F1C);      // Complementary warm tone
  
  // Status colors (keeping these universal)
  static const Color successGreen = Color(0xFF10B981);      // For improvements
  static const Color warningOrange = Color(0xFFF59E0B);     // For warnings
  static const Color errorRed = Color(0xFFEF4444);          // For declines
  static const Color infoBlue = Color(0xFF3B82F6);          // For info
  
  // Text colors - hierarchy for readability
  static const Color textPrimary = Color(0xFFF8FAFC);       // Almost white
  static const Color textSecondary = Color(0xFFCBD5E1);     // Light gray
  static const Color textTertiary = Color(0xFF64748B);      // Muted gray
  
  // Input fields
  static const Color inputBackground = Color(0xFF1E1E1E);
  
  // Gradients for premium feel
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFF5C842), Color(0xFFFFB347)], // Yellow to light orange
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1A1A1A), Color(0xFF0A0A0A)], // Dark gradient
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Metric-specific colors (adjusted for new theme)
  static const Color speedColor = Color(0xFFFF6B6B);        // Red-orange
  static const Color strengthColor = Color(0xFFF5C842);     // Your logo yellow!
  static const Color agilityColor = Color(0xFF6BCF7F);      // Light green
  static const Color enduranceColor = Color(0xFF4D96FF);    // Blue
}
