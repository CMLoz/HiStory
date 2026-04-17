import 'package:flutter/material.dart';
import 'package:history/ui/screens/rizal_game_screen.dart';
import 'package:history/ui/screens/bonifacio_game_screen.dart';
import 'package:history/ui/screens/luna_game_screen.dart';
import 'package:history/ui/theme/game_theme.dart';
import 'package:history/ui/theme/responsive.dart';
import 'package:history/ui/widgets/audio_image_button.dart';
import 'package:history/ui/widgets/pixel_background.dart';

class CharacterSelectScreen extends StatelessWidget {
  const CharacterSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = ResponsiveConstraints.getCharacterSelectMaxWidth(
      screenWidth,
    );

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
                    child: Text(
                      'SELECT CHARACTER',
                      style: GameTheme.headingStyle,
                    ),
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
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildCharacterOption(
                            context,
                            spriteAsset: 'assets/sprites/Rizal/rizal.png',
                            nameplateAsset: 'assets/images/rizal_nameplate.png',
                            onSelect: () {
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  transitionDuration: const Duration(
                                    seconds: 2,
                                  ),
                                  pageBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                      ) => const RizalGameScreen(),
                                  transitionsBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                        child,
                                      ) {
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
                            spriteAsset:
                                'assets/sprites/Bonifacio/bonifacio.png',
                            nameplateAsset: 'assets/images/boni_nameplate.png',
                            onSelect: () {
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  transitionDuration: const Duration(
                                    seconds: 2,
                                  ),
                                  pageBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                      ) => const BonifacioGameScreen(),
                                  transitionsBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                        child,
                                      ) {
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
                            spriteAsset: 'assets/sprites/Luna/luna.png',
                            nameplateAsset: 'assets/images/luna_nameplate.png',
                            onSelect: () {
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  transitionDuration: const Duration(
                                    seconds: 2,
                                  ),
                                  pageBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                      ) => const LunaGameScreen(),
                                  transitionsBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                        child,
                                      ) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        );
                                      },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
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
    required String spriteAsset,
    required String nameplateAsset,
    required VoidCallback onSelect,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final sizes = ResponsiveConstraints.getCharacterSelectSize(screenWidth);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: sizes.spriteHeight,
          width: sizes.spriteWidth,
          child: Image.asset(spriteAsset, fit: BoxFit.contain),
        ),
        const SizedBox(height: 10),
        // Nameplate Button
        AudioImageButton(
          assetPath: nameplateAsset,
          width: sizes.buttonWidth,
          onPressed: onSelect,
        ),
      ],
    );
  }
}
