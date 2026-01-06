import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData defaultTheme = ThemeData(
    colorScheme: .fromSeed(seedColor: Colors.deepPurple),
    primaryColor: Color.fromARGB(255, 39, 61, 254),
    scaffoldBackgroundColor: Color.fromARGB(255, 0, 25, 42),

    textTheme: TextTheme(
      displayLarge: TextStyle(
        color: Color.fromARGB(255, 37, 150, 190),
        fontWeight: FontWeight.bold,
        fontSize: 30,
      ),

      bodyMedium: TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
