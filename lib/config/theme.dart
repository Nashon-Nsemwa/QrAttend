import 'package:flutter/material.dart';

ThemeData lightmode = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: Color(0xFFF0F4FF),
  colorScheme: ColorScheme.light(
    primary: Color(0xFFF0F4FF), //scaffoldbc
    secondary: Colors.blue, //cards
    onPrimary: Colors.black, //texts
    onSecondary: Colors.white, //textfields/card
    onSecondaryContainer: const Color(0xFF2563EB), //signbuttons
    onPrimaryContainer: Colors.teal, //student role
    onPrimaryFixed: Colors.grey, //svg nav
    onSecondaryFixed: Colors.blue, //appbar
  ),
);
ThemeData darkmode = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Colors.grey.shade900,
  colorScheme: ColorScheme.dark(
    primary: Colors.grey.shade900,
    secondary: Colors.grey.shade800,
    onPrimary: Colors.grey.shade300,
    onSecondary: Colors.grey.shade800,
    onSecondaryContainer: const Color(0xFF2563EB),
    onPrimaryContainer: Colors.teal,
    onPrimaryFixed: Colors.grey,
    onSecondaryFixed: Colors.grey.shade900,
  ),
);
