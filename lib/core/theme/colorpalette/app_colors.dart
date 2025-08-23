import 'package:flutter/material.dart';

/// Three-tone purple color palette following 60-30-10 principle
class AppColors {
  // 60% - Dominant/Neutral Colors
  static const Color lightBackground = Color(0xFFFAF9FC); // Very light purple-tinted white
  static const Color darkBackground = Color(0xFF1A1625); // Deep charcoal with purple undertones
  static const Color lightSurface = Color(0xFFFFFFFF); // Pure white for cards/surfaces
  static const Color darkSurface = Color(0xFF2D2438); // Dark purple-gray for cards/surfaces
  
  // 30% - Secondary Colors
  static const Color lightSecondary = Color(0xFFE8E4F0); // Light purple-gray
  static const Color darkSecondary = Color(0xFF3D3451); // Medium purple-gray
  static const Color lightSecondaryVariant = Color(0xFFD1C9E0); // Slightly darker light purple-gray
  static const Color darkSecondaryVariant = Color(0xFF4A4060); // Lighter dark purple-gray
  
  // 10% - Accent/Primary Colors
  static const Color primaryPurple = Color(0xFF7C4DFF); // Vibrant purple
  static const Color primaryPurpleDark = Color(0xFF651FFF); // Darker purple for dark theme
  static const Color primaryPurpleLight = Color(0xFF9575FF); // Lighter purple variant
  
  // Text Colors
  static const Color lightOnSurface = Color(0xFF2D2438); // Dark purple-gray text on light
  static const Color darkOnSurface = Color(0xFFF5F4F7); // Light text on dark
  static const Color lightOnPrimary = Color(0xFFFFFFFF); // White text on purple
  static const Color darkOnPrimary = Color(0xFFFFFFFF); // White text on purple
  
  // Additional text colors for better hierarchy
  static const Color lightOnBackground = Color(0xFF1A1625); // Primary text on light background
  static const Color darkOnBackground = Color(0xFFF5F4F7); // Primary text on dark background
  
  // Supporting Colors
  static const Color error = Color(0xFFE53E3E);
  static const Color success = Color(0xFF38A169);
  static const Color warning = Color(0xFFD69E2E);
  static const Color info = Color(0xFF3182CE);
  
  // Border and Divider Colors
  static const Color lightBorder = Color(0xFFE8E4F0);
  static const Color darkBorder = Color(0xFF3D3451);
  static const Color lightDivider = Color(0xFFD1C9E0);
  static const Color darkDivider = Color(0xFF4A4060);
  
  // Gradient definitions for cards and components
  static const List<Color> purpleGradient = [
    Color(0xFF7C4DFF), // primaryPurple
    Color(0xFF651FFF), // primaryPurpleDark
  ];
  
  static const List<Color> lightGradient = [
    Color(0xFFE8E4F0), // lightSecondary
    Color(0xFFD1C9E0), // lightSecondaryVariant
  ];
  
  static const List<Color> darkGradient = [
    Color(0xFF3D3451), // darkSecondary
    Color(0xFF4A4060), // darkSecondaryVariant
  ];
  
  // Opacity variants for overlays and subtle effects
  static Color get lightOverlay => lightOnSurface.withOpacity(0.05);
  static Color get darkOverlay => darkOnSurface.withOpacity(0.05);
  static Color get primaryOverlay => primaryPurple.withOpacity(0.1);
}
