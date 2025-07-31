import 'package:flutter/material.dart';
import 'font_styles.dart'; // <-- your font styles file

final TextTheme customTextTheme = TextTheme(
  displayLarge: FontStyles.ptSans24Bold,
  displayMedium: FontStyles.ptSans22Bold,
  displaySmall: FontStyles.ptSans20Bold,
  headlineLarge: FontStyles.ptSans18Bold,
  headlineMedium: FontStyles.ptSans16Bold,
  headlineSmall: FontStyles.ptSans14Bold,
  titleLarge: FontStyles.ptSans13Normal,
  titleMedium: FontStyles.ptSans12Normal,
  titleSmall: FontStyles.ptSans11Normal,
  bodyLarge: FontStyles.ptSans16Normal,
  bodyMedium: FontStyles.ptSans14Normal,
  bodySmall: FontStyles.ptSans12Normal,
  labelLarge: FontStyles.ptSans14Bold,
  labelMedium: FontStyles.ptSans12Bold,
  labelSmall: FontStyles.ptSans11Bold,
);
