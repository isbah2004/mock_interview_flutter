import 'package:flutter/material.dart';
import '../colorpalette/light_theme.dart';
import '../fontstyle/light_text_theme.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: LightThemePalette.primary,
  scaffoldBackgroundColor: LightThemePalette.surface,
  textTheme: customTextTheme,
  appBarTheme: AppBarTheme(
    backgroundColor: LightThemePalette.primary,
    foregroundColor: LightThemePalette.onPrimary,
    elevation: 0,
  ),

   inputDecorationTheme: InputDecorationTheme(
    hintStyle: TextStyle(
      color: LightThemePalette.onSurface,  
      fontSize: 14,
      fontFamily: 'PTSansCaption',
    ),
        enabledBorder: _border(LightThemePalette.stroke),
        filled: true,
        fillColor: LightThemePalette.onPrimary,
        border: _border(LightThemePalette.stroke),
        focusedBorder: _border(LightThemePalette.secondary),
        errorBorder: _border(LightThemePalette.error),
        disabledBorder: _border(LightThemePalette.gray600),
        focusedErrorBorder: _border(LightThemePalette.error),
      ),
  colorScheme: ColorScheme.light(
    primary: LightThemePalette.primary,
    onPrimary: LightThemePalette.onPrimary,
    secondary: LightThemePalette.secondary,
    surface: LightThemePalette.surface,
    onSurface: LightThemePalette.onSurface,
  ),
  dividerColor: LightThemePalette.stroke,
);
   _border([Color color = LightThemePalette.stroke]) => OutlineInputBorder(
        borderSide: BorderSide(
          color: color,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(20),
      );