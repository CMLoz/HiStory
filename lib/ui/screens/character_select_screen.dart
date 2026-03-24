import 'package:flutter/material.dart';
import 'package:history/ui/screens/chapter_title_screen.dart';
import 'package:history/ui/screens/rizal_game_screen.dart';
import 'package:history/ui/theme/game_theme.dart';
import 'package:history/ui/widgets/audio_image_button.dart';
import 'package:history/ui/widgets/pixel_background.dart';

class CharacterSelectScreen extends StatelessWidget {
  const CharacterSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PixelBackground(
        overlayOpacity: 0.5,
        child: SafeArea(
          child: Column(
            children: [
              // Header Stack
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Text('SELECT CHARACTER', style: GameTheme.headingStyle),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: AudioImageButton(
                        assetPath: 'assets/images/Back Square Button.png',
                        width: 64,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),

              // Character Selection Area
              Expanded(
                child: SingleChildScrollView(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildCharacterOption(
                      context, 
                      nameplateAsset: 'assets/images/rizal_nameplate.png',
                      onSelect: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            transitionDuration: const Duration(seconds: 2),
                            pageBuilder: (context, animation, secondaryAnimation) => const ChapterTitleScreen(
                              chapterTitle: 'Chapter 1',
                              subtitle: 'The Departure',
                              nextScreen: RizalGameScreen(),
                            ),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                    ),
                    _buildCharacterOption(
                      context, 
                      nameplateAsset: 'assets/images/boni_nameplate.png',
                      onSelect: () {
                        // TODO: Handle Bonifacio selection
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Bonifacio Selected')),
                        );
                      },
                    ),
                    _buildCharacterOption(
                      context, 
                      nameplateAsset: 'assets/images/luna_nameplate.png',
                      onSelect: () {
                        // TODO: Handle Luna selection
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Luna Selected')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildCharacterOption(
    BuildContext context, {
    required String nameplateAsset,
    required VoidCallback onSelect,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Placeholder space for Sprite
        Container(
          height: 120, // Enough space for a sprite later
          width: 100,
          alignment: Alignment.bottomCenter,
          child: const SizedBox(), // Add character sprite here in the future
        ),
        const SizedBox(height: 10),
        // Nameplate Button
        AudioImageButton(
          assetPath: nameplateAsset,
          width: 100, // Adjust width based on images
          onPressed: onSelect,
        ),
      ],
    );
  }
}
