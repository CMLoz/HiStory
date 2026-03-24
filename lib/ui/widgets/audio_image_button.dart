import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Adjust import if needed:
import 'package:history/core/audio/audio_controller.dart';

class AudioImageButton extends ConsumerWidget {
  final String assetPath;
  final VoidCallback onPressed;
  final double width;

  const AudioImageButton({
    super.key,
    required this.assetPath,
    required this.onPressed,
    this.width = 160,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          // Use Riverpod provider to play SFX, respecting user settings
          ref
              .read(audioControllerProvider.notifier)
              .playSfx('button-click.mp3');
          onPressed();
        },
        child: Image.asset(assetPath, width: width, fit: BoxFit.contain),
      ),
    );
  }
}
