import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChapterTitleScreen extends StatefulWidget {
  final String chapterTitle;
  final String? subtitle;
  final Widget nextScreen;

  const ChapterTitleScreen({
    super.key,
    required this.chapterTitle,
    this.subtitle,
    required this.nextScreen,
  });

  @override
  State<ChapterTitleScreen> createState() => _ChapterTitleScreenState();
}

class _ChapterTitleScreenState extends State<ChapterTitleScreen> {
  double _textOpacity = 0.0;
  double _screenOpacity = 1.0; // Screen starts fully visible (black)

  @override
  void initState() {
    super.initState();
    _runSequence();
  }

  Future<void> _runSequence() async {
    // Short pause before text appears
    await Future.delayed(const Duration(milliseconds: 500));

    // Fade text in
    if (mounted) setState(() => _textOpacity = 1.0);

    // Hold text
    await Future.delayed(const Duration(milliseconds: 2500));

    // Fade text out
    if (mounted) setState(() => _textOpacity = 0.0);
    await Future.delayed(const Duration(milliseconds: 1200));

    // Fade entire screen out to black (fade out the white overlay = fade in black)
    if (mounted) setState(() => _screenOpacity = 0.0);
    await Future.delayed(const Duration(milliseconds: 1000));

    // Navigate to next screen
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(seconds: 2),
          pageBuilder: (context, animation, secondaryAnimation) => widget.nextScreen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedOpacity(
        opacity: _screenOpacity,
        duration: const Duration(milliseconds: 1000),
        child: Container(
          color: Colors.black,
          child: Center(
            child: AnimatedOpacity(
              opacity: _textOpacity,
              duration: const Duration(milliseconds: 1200),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.chapterTitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cinzelDecorative(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                      letterSpacing: 6,
                      shadows: [
                        const Shadow(
                          color: Colors.amber,
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      widget.subtitle!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cinzel(
                        fontSize: 16,
                        color: Colors.white70,
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
