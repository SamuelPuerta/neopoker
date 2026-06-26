import 'package:flutter/material.dart';

class AppTypography {
  static const String orbitron = 'Orbitron';
  static const String rajdhani = 'Rajdhani';

  static const headingLarge = TextStyle(
    fontFamily: orbitron,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: 2,
  );

  static const headingMedium = TextStyle(
    fontFamily: orbitron,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
  );

  static const bodyLarge = TextStyle(
    fontFamily: rajdhani,
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );

  static const bodyMedium = TextStyle(
    fontFamily: rajdhani,
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static const bodySmall = TextStyle(
    fontFamily: rajdhani,
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static const labelLarge = TextStyle(
    fontFamily: orbitron,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 1,
  );

  static const labelSmall = TextStyle(
    fontFamily: orbitron,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1,
  );
}
