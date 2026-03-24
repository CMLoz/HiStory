import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:history/core/audio/audio_controller.dart';
import 'package:history/ui/screens/options_screen.dart';
import 'package:history/ui/theme/game_theme.dart';
import 'package:history/ui/widgets/audio_image_button.dart';
import 'package:history/ui/widgets/pixel_background.dart';
import 'package:history/ui/screens/character_select_screen.dart';

class MainMenuScreen extends ConsumerStatefulWidget {
  const MainMenuScreen({super.key});

  @override
  ConsumerState<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends ConsumerState<MainMenuScreen> {
  @override
  void initState() {
    super.initState();
    // Start background music loop
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioControllerProvider.notifier)
        ..setBgmVolume(0.2) // Weekly (weakly) volume
        ..startBgm();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PixelBackground(
        overlayOpacity: 0.0,
        child: SafeArea(
          child: Column(
            children: [
              // Logo/Title at the top
              Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                child: Text(
                  'His Story',
                  style: GameTheme.titleStyle,
                  textAlign: TextAlign.center,
                ),
              ),

              // Spacer to push buttons down if needed, or Expanded
              // Using Expanded with Center inside to center buttons vertically in remaining space
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(flex: 2),
                        AudioImageButton(
                          assetPath: 'assets/images/Play Button.png',
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const CharacterSelectScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 15),
                        AudioImageButton(
                          assetPath: 'assets/images/Options Button.png',
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const OptionsScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 15),
                        AudioImageButton(
                          assetPath: 'assets/images/Quit Button.png',
                          onPressed: () {
                            SystemNavigator.pop();
                          },
                        ),
                        const Spacer(flex: 3),
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
}
