import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GameSlider extends StatelessWidget {
  final String title;
  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;

  const GameSlider({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 0.0, bottom: 8.0),
          child: Text(
            title,
            style: GoogleFonts.pressStart2p(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ),
        Slider(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.green,
          inactiveColor: Colors.white24,
          min: min,
          max: max,
        ),
      ],
    );
  }
}
