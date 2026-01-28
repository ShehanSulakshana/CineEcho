import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData defaultTheme = ThemeData(
    colorScheme: .fromSeed(seedColor: Colors.deepPurple),
    primaryColor: Color.fromARGB(255, 39, 61, 254),
    scaffoldBackgroundColor: Color.fromARGB(255, 0, 25, 42),
    cardColor: Color.fromARGB(255, 10, 40, 60),

    textTheme: TextTheme(
      displayLarge: TextStyle(
        color: Color.fromARGB(255, 37, 150, 190),
        fontWeight: FontWeight.bold,
        fontSize: 30,
      ),

      bodyLarge: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 30,
      ),

      bodyMedium: TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),

      titleMedium: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),

      bodySmall: TextStyle(color: Colors.white, fontSize: 15),

      titleSmall: TextStyle(
        color: Color.fromARGB(255, 37, 150, 190),
        fontWeight: FontWeight.bold,
        fontSize: 15,
      ),

      displayMedium: TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w900,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF0A2A3A),
      contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),

      hintStyle: TextStyle(
        color: const Color.fromARGB(95, 255, 255, 255),
        fontSize: 15,
      ),
      labelStyle: TextStyle(
        color: Color(0xFF2596BE),
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: BorderSide(color: Colors.white24),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: BorderSide(color: Color(0xFF2596BE), width: 2),
      ),
    ),

    appBarTheme: AppBarTheme(
      //foregroundColor: Color.fromARGB(255, 39, 61, 254),
      backgroundColor: Color.fromARGB(255, 0, 25, 42),
      elevation: 2.5,
      shadowColor: const Color.fromARGB(36, 0, 0, 0),
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Color.fromARGB(255, 39, 61, 254),
        fontWeight: FontWeight.bold,
        fontSize: 27,
      ),
      iconTheme: IconThemeData(
        size: 27,
        color: Color.fromARGB(255, 39, 61, 254),
      ),
    ),

    // snackBarTheme: SnackBarThemeData(
    //   backgroundColor: Color.fromARGB(255, 39, 61, 254),
    // )
  );
}
