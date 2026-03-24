import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GameToggle extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const GameToggle({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.pressStart2p(fontSize: 16, color: Colors.white),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.green, // Assuming GameTheme.accentColor is not defined in this snippet, using Colors.green as a placeholder or if that was the intent.
          activeTrackColor: Colors.white24,
        ),
      ],
    );
  }
}
