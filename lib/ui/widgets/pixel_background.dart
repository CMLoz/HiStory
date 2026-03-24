import 'package:flutter/material.dart';

class PixelBackground extends StatelessWidget {
  final Widget child;
  final double overlayOpacity;

  const PixelBackground({
    super.key,
    required this.child,
    this.overlayOpacity = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: Image(
            image: AssetImage('assets/images/pixel_art_large.png'),
            fit: BoxFit.cover,
          ),
        ),

        if (overlayOpacity > 0)
          Positioned.fill(
            child: Container(
                color: Colors.black.withValues(alpha: overlayOpacity)),
          ),
        Positioned.fill(child: child),
      ],
    );
  }
}
