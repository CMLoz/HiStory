import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GameTheme {
  static TextStyle get titleStyle => GoogleFonts.pressStart2p(
    fontSize: 60,
    color: Colors.white,
    shadows: [
      const Shadow(offset: Offset(4, 4), blurRadius: 0, color: Colors.black),
    ],
  );

  static TextStyle get headingStyle =>
      GoogleFonts.pressStart2p(fontSize: 40, color: Colors.white);

  static TextStyle get bodyStyle =>
      GoogleFonts.pressStart2p(fontSize: 16, color: Colors.white);

  static TextStyle get labelStyle =>
      GoogleFonts.pressStart2p(fontSize: 12, color: Colors.white70);
}
