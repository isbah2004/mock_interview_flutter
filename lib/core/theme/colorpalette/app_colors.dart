import 'package:flutter/material.dart';
import 'package:mock_interview/core/utils/color_compat.dart';

/// Three-tone purple color palette following 60-30-10 principle
class AppColors {
  // 60% - Dominant/Neutral Colors
  static const Color lightBackground = Color(
    0xFFFAF9FC,
  ); // Very light purple-tinted white
  static const Color darkBackground = Color(
    0xFF0F0D1A,
  ); // Deeper, richer dark background
  static const Color lightSurface = Color(
    0xFFFFFFFF,
  ); // Pure white for cards/surfaces
  static const Color darkSurface = Color(
    0xFF1E1B2E,
  ); // Elevated dark surface with better contrast

  // 30% - Secondary Colors
  static const Color lightSecondary = Color(0xFFE8E4F0); // Light purple-gray
  static const Color darkSecondary = Color(
    0xFF2A2540,
  ); // Enhanced medium purple-gray
  static const Color lightSecondaryVariant = Color(
    0xFFD1C9E0,
  ); // Slightly darker light purple-gray
  static const Color darkSecondaryVariant = Color(
    0xFF362F4A,
  ); // Improved lighter dark purple-gray

  // 10% - Accent/Primary Colors
  static const Color primaryPurple = Color(0xFF7C4DFF); // Vibrant purple
  static const Color primaryPurpleDark = Color(
    0xFF8B5CF6,
  ); // Brighter purple for dark theme - better visibility
  static const Color primaryPurpleLight = Color(
    0xFF9575FF,
  ); // Lighter purple variant

  // Text Colors
  static const Color lightOnSurface = Color(
    0xFF2D2438,
  ); // Dark purple-gray text on light
  static const Color darkOnSurface = Color(
    0xFFF8F7FA,
  ); // Improved light text on dark with better contrast
  static const Color lightOnPrimary = Color(0xFFFFFFFF); // White text on purple
  static const Color darkOnPrimary = Color(0xFFFFFFFF); // White text on purple

  // Additional text colors for better hierarchy
  static const Color lightOnBackground = Color(
    0xFF1A1625,
  ); // Primary text on light background
  static const Color darkOnBackground = Color(
    0xFFF8F7FA,
  ); // Improved primary text on dark background

  // Supporting Colors
  static const Color error = Color(0xFFE53E3E);
  static const Color success = Color(0xFF38A169);
  static const Color warning = Color(0xFFD69E2E);
  static const Color info = Color(0xFF3182CE);

  // Border and Divider Colors
  static const Color lightBorder = Color(0xFFE8E4F0);
  static const Color darkBorder = Color(
    0xFF2A2540,
  ); // Updated to match new secondary
  static const Color lightDivider = Color(0xFFD1C9E0);
  static const Color darkDivider = Color(
    0xFF362F4A,
  ); // Updated to match new secondary variant

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
    Color(0xFF2A2540), // darkSecondary - updated to match
    Color(0xFF362F4A), // darkSecondaryVariant - updated to match
  ];

  // Opacity variants for overlays and subtle effects
  // Use compatibility helper to avoid deprecated withOpacity analyzer lint
  static Color get lightOverlay => lightOnSurface.withOpacityCompat(0.05);
  static Color get darkOverlay => darkOnSurface.withOpacityCompat(0.05);
  static Color get primaryOverlay => primaryPurple.withOpacityCompat(0.1);
}
