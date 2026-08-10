import 'package:flutter/material.dart';

ThemeData buildLightTheme() {
  const seed = Color(0xFF0B4F6C);
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
    visualDensity: VisualDensity.compact,
  );
}

ThemeData buildDarkTheme() {
  const seed = Color(0xFF7EB8DA);
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
    visualDensity: VisualDensity.compact,
  );
}
