import 'package:flutter/material.dart';
import '../colorpalette/dark_theme.dart';
import '../fontstyle/light_text_theme.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: DarkThemePalette.primary,
  scaffoldBackgroundColor: DarkThemePalette.surface,
  textTheme: customTextTheme.apply(
    bodyColor: DarkThemePalette.onSurface,
    displayColor: DarkThemePalette.onSurface,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: DarkThemePalette.surface,
    foregroundColor: DarkThemePalette.onSurface,
    elevation: 0,
    shadowColor: Colors.transparent,
  ),
  cardTheme: CardThemeData(
    color: DarkThemePalette.cardBackground,
    elevation: 4,
    shadowColor: Colors.black26,
  ),
  inputDecorationTheme: InputDecorationTheme(
    hintStyle: TextStyle(
      color: DarkThemePalette.gray500,
      fontSize: 14,
      fontFamily: 'PTSansCaption',
    ),
    enabledBorder: _darkBorder(DarkThemePalette.stroke),
    filled: true,
    fillColor: DarkThemePalette.gray100,
    border: _darkBorder(DarkThemePalette.stroke),
    focusedBorder: _darkBorder(DarkThemePalette.primary),
    errorBorder: _darkBorder(DarkThemePalette.error),
    disabledBorder: _darkBorder(DarkThemePalette.gray400),
    focusedErrorBorder: _darkBorder(DarkThemePalette.error),
  ),
  colorScheme: ColorScheme.dark(
    primary: DarkThemePalette.primary,
    onPrimary: DarkThemePalette.onPrimary,
    secondary: DarkThemePalette.secondary,
    surface: DarkThemePalette.surface,
    onSurface: DarkThemePalette.onSurface,
    error: DarkThemePalette.error,
    onError: DarkThemePalette.onError,
  ),
  dividerColor: DarkThemePalette.divider,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: DarkThemePalette.primary,
      foregroundColor: DarkThemePalette.onPrimary,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: DarkThemePalette.primary,
      side: BorderSide(color: DarkThemePalette.primary),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: DarkThemePalette.primary),
  ),
);

OutlineInputBorder _darkBorder([Color color = DarkThemePalette.stroke]) =>
    OutlineInputBorder(
      borderSide: BorderSide(color: color, width: 2),
      borderRadius: BorderRadius.circular(20),
    );
