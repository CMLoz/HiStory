import 'package:flutter/material.dart';
import 'package:history/core/dialogue_sprite_assets.dart';
import 'package:history/ui/theme/responsive.dart';

class DialogueSpriteOverlay extends StatelessWidget {
  final String storyKey;
  final String speakerName;

  const DialogueSpriteOverlay({
    super.key,
    required this.storyKey,
    required this.speakerName,
  });

  @override
  Widget build(BuildContext context) {
    final assetPath = resolveDialogueSpriteAsset(
      storyKey: storyKey,
      speakerName: speakerName,
    );
    if (assetPath == null) {
      return const SizedBox.shrink();
    }

    final bool isLeft = isLeftSpriteSpeaker(speakerName);
    final screenWidth = MediaQuery.of(context).size.width;

    // Use responsive values based on platform
    final bottomOffset = ResponsiveConstraints.getSpriteBottomOffset(
      screenWidth,
    );
    final widthFraction = ResponsiveConstraints.getSpriteWidthFraction(
      screenWidth,
    );

    return Positioned.fill(
      child: IgnorePointer(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: isLeft ? 155 : 0,
              right: isLeft ? 0 : 20,
              top: 24,
              bottom: bottomOffset,
            ),
            child: Align(
              alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: widthFraction,
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
