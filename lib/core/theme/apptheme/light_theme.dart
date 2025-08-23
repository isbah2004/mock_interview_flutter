import 'package:flutter/material.dart';
import 'package:mock_interview/core/theme/colorpalette/app_colors.dart';

class LightTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color Scheme - 60-30-10 Purple Theme
      colorScheme: const ColorScheme.light(
        // 10% - Primary accent color
        primary: AppColors.primaryPurple,
        onPrimary: AppColors.lightOnPrimary,
        primaryContainer: AppColors.primaryPurpleLight,
        onPrimaryContainer: AppColors.lightOnSurface,
        
        // 30% - Secondary colors
        secondary: AppColors.lightSecondary,
        onSecondary: AppColors.lightOnSurface,
        secondaryContainer: AppColors.lightSecondaryVariant,
        onSecondaryContainer: AppColors.lightOnSurface,
        
        // 60% - Dominant background colors
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightOnSurface,
        background: AppColors.lightBackground,
        onBackground: AppColors.lightOnSurface,
        
        // Supporting colors
        error: AppColors.error,
        onError: Colors.white,
        outline: AppColors.lightBorder,
        outlineVariant: AppColors.lightDivider,
      ),
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightOnSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.lightOnSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Card Theme
      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 2,
        shadowColor: AppColors.primaryPurple.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        hintStyle: const TextStyle(
          color: Color(0xFF9E9E9E),
          fontSize: 16,
        ),
        prefixIconColor: AppColors.primaryPurple,
        suffixIconColor: AppColors.primaryPurple,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.lightBorder,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.lightBorder,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.primaryPurple,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPurple,
          foregroundColor: AppColors.lightOnPrimary,
          elevation: 2,
          shadowColor: AppColors.primaryPurple.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.lightDivider,
        thickness: 1,
        space: 1,
      ),
      
      // Scaffold Background
      scaffoldBackgroundColor: AppColors.lightBackground,
    );
  }
}
