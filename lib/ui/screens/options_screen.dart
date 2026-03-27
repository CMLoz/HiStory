import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:history/core/audio/audio_controller.dart';
import 'package:history/providers/settings_provider.dart';
import 'package:history/ui/theme/game_theme.dart';
import 'package:history/ui/widgets/game_panel.dart';
import 'package:history/ui/widgets/game_slider.dart';
import 'package:history/ui/widgets/audio_image_button.dart';
import 'package:history/ui/widgets/game_toggle.dart';
import 'package:history/ui/widgets/pixel_background.dart';

class OptionsScreen extends ConsumerWidget {
  const OptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioSettings = ref.watch(audioControllerProvider);
    final audioController = ref.read(audioControllerProvider.notifier);
    final int textSpeedMs = ref.watch(textSpeedProvider);
    final textSpeedNotifier = ref.read(textSpeedProvider.notifier);

    // Convert ms-per-char to a 0.0–1.0 slider value
    // Slow=60ms -> 0.0, Normal=30ms -> 0.5, Fast=10ms -> 1.0
    String speedLabel;
    if (textSpeedMs >= 50) {
      speedLabel = 'Slow';
    } else if (textSpeedMs >= 25) {
      speedLabel = 'Normal';
    } else {
      speedLabel = 'Fast';
    }

    return Scaffold(
      body: PixelBackground(
        overlayOpacity: 0.5,
        child: Stack(
          children: [
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
              child: GamePanel(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('OPTIONS', style: GameTheme.headingStyle),
                    const SizedBox(height: 40),

                    // BGM Toggle
                    GameToggle(
                      title: 'Background Music',
                      value: audioSettings.isBgmEnabled,
                      onChanged: (value) => audioController.toggleBgm(value),
                    ),

                    if (audioSettings.isBgmEnabled) ...[
                      const SizedBox(height: 10),
                      GameSlider(
                        title: 'Volume',
                        value: audioSettings.bgmVolume,
                        onChanged: (value) =>
                            audioController.setBgmVolume(value),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // SFX Toggle
                    GameToggle(
                      title: 'Sound Effects',
                      value: audioSettings.isSfxEnabled,
                      onChanged: (value) => audioController.toggleSfx(value),
                    ),

                    const SizedBox(height: 20),

                    // Text Speed Slider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Text Speed',
                          style: GoogleFonts.pressStart2p(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          speedLabel,
                          style: GoogleFonts.pressStart2p(
                            fontSize: 12,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: (70 - textSpeedMs).toDouble(),
                      min: 10,
                      max: 60,
                      // Left (10) = 70-10 = 60ms (Slow)
                      // Right (60) = 70-60 = 10ms (Fast)
                      onChanged: (value) =>
                          textSpeedNotifier.setSpeed((70 - value).round()),
                      activeColor: Colors.amber,
                      inactiveColor: Colors.white24,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SafeArea(
          child: Align(
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
            ),
          ],
        ),
      ),
    );
  }
}
