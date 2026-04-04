import 'package:flutter/material.dart';

class BoringTheme {
  static final dark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    colorScheme: const ColorScheme.dark(
      primary: Colors.white,
      secondary: Colors.grey,
      surface: Colors.black,
      background: Colors.black,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 48, fontWeight: FontWeight.w200, color: Colors.white70),
      displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w300, color: Colors.white60),
      bodyLarge: TextStyle(fontSize: 18, color: Colors.white70),
      bodyMedium: TextStyle(fontSize: 16, color: Colors.white54),
    ),
    useMaterial3: true,
  );
}
