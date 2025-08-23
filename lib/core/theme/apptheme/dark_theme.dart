import 'package:flutter/material.dart';
import 'package:mock_interview/core/theme/colorpalette/app_colors.dart';

class DarkTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Color Scheme - 60-30-10 Purple Theme
      colorScheme: const ColorScheme.dark(
        // 10% - Primary accent color
        primary: AppColors.primaryPurpleDark,
        onPrimary: AppColors.darkOnPrimary,
        primaryContainer: AppColors.primaryPurple,
        onPrimaryContainer: AppColors.darkOnSurface,
        
        // 30% - Secondary colors
        secondary: AppColors.darkSecondary,
        onSecondary: AppColors.darkOnSurface,
        secondaryContainer: AppColors.darkSecondaryVariant,
        onSecondaryContainer: AppColors.darkOnSurface,
        
        // 60% - Dominant background colors
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkOnSurface,
        background: AppColors.darkBackground,
        onBackground: AppColors.darkOnSurface,
        
        // Supporting colors
        error: AppColors.error,
        onError: Colors.white,
        outline: AppColors.darkBorder,
        outlineVariant: AppColors.darkDivider,
      ),
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkOnSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.darkOnSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        hintStyle: const TextStyle(
          color: Color(0xFF9E9E9E),
          fontSize: 16,
        ),
        prefixIconColor: AppColors.primaryPurpleDark,
        suffixIconColor: AppColors.primaryPurpleDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.darkBorder,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.darkBorder,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.primaryPurpleDark,
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
          backgroundColor: AppColors.primaryPurpleDark,
          foregroundColor: AppColors.darkOnPrimary,
          elevation: 4,
          shadowColor: AppColors.primaryPurpleDark.withOpacity(0.4),
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
          foregroundColor: AppColors.primaryPurpleDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.darkDivider,
        thickness: 1,
        space: 1,
      ),
      
      // Scaffold Background
      scaffoldBackgroundColor: AppColors.darkBackground,
    );
  }
}
