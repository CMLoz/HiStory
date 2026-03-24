import 'package:flutter/material.dart';

class GamePanel extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsets padding;

  const GamePanel({
    super.key,
    required this.child,
    this.maxWidth = 600,
    this.padding = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8), // Semi-transparent black background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: child,
    );
  }
}
