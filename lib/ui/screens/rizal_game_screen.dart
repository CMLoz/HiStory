import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:history/providers/game_state.dart';
import 'package:history/providers/settings_provider.dart';
import 'package:history/ui/theme/game_theme.dart';
import 'package:history/ui/widgets/audio_image_button.dart';
import 'package:history/ui/widgets/typewriter_text.dart';
import 'package:history/ui/screens/main_menu_screen.dart';
import 'package:history/ui/screens/options_screen.dart';

class RizalGameScreen extends ConsumerStatefulWidget {
  const RizalGameScreen({super.key});

  @override
  ConsumerState<RizalGameScreen> createState() => _RizalGameScreenState();
}

class _RizalGameScreenState extends ConsumerState<RizalGameScreen> {
  double _opacity = 0.0;
  bool _assetsLoaded = false;
  bool _sceneAssetsLoaded = false;
  bool _isPaused = false;
  final GlobalKey<TypewriterTextState> _typewriterKey =
      GlobalKey<TypewriterTextState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_assetsLoaded) {
      _preloadStaticAssets();
      _assetsLoaded = true;
    }
  }

  Future<void> _preloadStaticAssets() async {
    await Future.wait([
      precacheImage(
        const AssetImage('assets/images/dialogue_box.png'),
        context,
      ),
      precacheImage(
        const AssetImage('assets/images/Pause Square Button.png'),
        context,
      ),
    ]);

    if (mounted) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _opacity = 1.0;
          });
        }
      });
    }
  }

  void _preloadSceneAssets(List<DialogueNode> nodes) {
    if (_sceneAssetsLoaded || !mounted) return;

    final uniqueImages = nodes.map((n) => n.bgImage).toSet();
    for (var imgPath in uniqueImages) {
      if (imgPath.isNotEmpty && mounted) {
        precacheImage(AssetImage(imgPath), context);
      }
    }
    _sceneAssetsLoaded = true;
  }

  @override
  Widget build(BuildContext context) {
    final asyncNodes = ref.watch(dialogueNodesProvider);
    final GameStateNotifier gameNotifier = ref.read(gameStateProvider.notifier);
    final int textSpeedMs = ref.watch(textSpeedProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: asyncNodes.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.amber)),
        error: (error, stack) => const Center(
          child: Text(
            'Error loading dialogue',
            style: TextStyle(color: Colors.white),
          ),
        ),
        data: (nodes) {
          // Preload all chapter assets safely
          if (!_sceneAssetsLoaded) {
            // Defer to next frame to avoid build-phase locking if precache takes significant time (though it returns Future)
            // But since we just want to fire it off:
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _preloadSceneAssets(nodes);
            });
          }

          final int dialogueIndex = ref.watch(gameStateProvider);
          final DialogueNode currentNode = nodes[dialogueIndex];
          final bool isChoice = currentNode.isChoice;

          return GestureDetector(
            // Only allow tap-to-advance on normal dialogue nodes
            onTap: isChoice || _isPaused
                ? null
                : () {
                    if (_typewriterKey.currentState?.isFinished == false) {
                      _typewriterKey.currentState?.completeText();
                    } else {
                      gameNotifier.nextDialogue(nodes.length);
                    }
                  },
            child: AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(seconds: 2),
              child: Stack(
                children: [
                  // Background Image with Fade Transition
                  Positioned.fill(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 1000),
                      child: Image.asset(
                        currentNode.bgImage,
                        key: ValueKey<String>(currentNode.bgImage),
                        fit: BoxFit.cover,
                        gaplessPlayback:
                            true, // Prevents flickering during load
                      ),
                    ),
                  ),

                  // — CHOICE UI —
                  if (isChoice)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: currentNode.choices!.map((choice) {
                            return _ChoiceBox(
                              choice: choice,
                              onTap: () =>
                                  gameNotifier.jumpTo(choice.nextIndex),
                            );
                          }).toList(),
                        ),
                      ),
                    )
                  // — NORMAL DIALOGUE BOX —
                  else
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              'assets/images/dialogue_box.png',
                              width: MediaQuery.of(context).size.width * 0.95,
                              height: 200,
                              fit: BoxFit.fill,
                            ),
                            Positioned(
                              top: 40,
                              left: 70,
                              right: 100,
                              bottom: 40,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (currentNode.speakerName.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 8.0,
                                      ),
                                      child: Text(
                                        currentNode.speakerName,
                                        style: GameTheme.headingStyle.copyWith(
                                          fontSize: 18,
                                          color: Colors.amber,
                                          shadows: [
                                            const Shadow(
                                              color: Colors.black,
                                              offset: Offset(2, 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  Expanded(
                                    child: TypewriterText(
                                      currentNode.text,
                                      key: _typewriterKey,
                                      speed: Duration(
                                        milliseconds: textSpeedMs,
                                      ),
                                      style: GameTheme.bodyStyle.copyWith(
                                        fontSize: 15,
                                        color: Colors.white,
                                        shadows: [
                                          const Shadow(
                                            color: Colors.black,
                                            offset: Offset(1, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Pause Button
                  Align(
                    alignment: Alignment.topRight,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: AudioImageButton(
                          assetPath: 'assets/images/Pause Square Button.png',
                          width: 64,
                          onPressed: () {
                            setState(() {
                              _isPaused = true;
                            });
                          },
                        ),
                      ),
                    ),
                  ),

                  // Pause Menu Overlay
                  if (_isPaused)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.7),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AudioImageButton(
                                assetPath:
                                    'assets/images/Home Square Button.png',
                                width: 80,
                                onPressed: () {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    PageRouteBuilder(
                                      transitionDuration: const Duration(
                                        seconds: 2,
                                      ),
                                      pageBuilder:
                                          (
                                            context,
                                            animation,
                                            secondaryAnimation,
                                          ) => const MainMenuScreen(),
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
                                    (route) => false,
                                  );
                                },
                              ),
                              const SizedBox(width: 40),
                              AudioImageButton(
                                assetPath:
                                    'assets/images/Settings Square Button.png',
                                width: 80,
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const OptionsScreen(),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 40),
                              AudioImageButton(
                                assetPath:
                                    'assets/images/Back Square Button.png',
                                width: 80,
                                onPressed: () {
                                  setState(() {
                                    _isPaused = false;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// A single interactive choice box, reusing the dialogue_box asset.
class _ChoiceBox extends StatefulWidget {
  final ChoiceOption choice;
  final VoidCallback onTap;

  const _ChoiceBox({required this.choice, required this.onTap});

  @override
  State<_ChoiceBox> createState() => _ChoiceBoxState();
}

class _ChoiceBoxState extends State<_ChoiceBox> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.44;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _hovered = true),
      onTapCancel: () => setState(() => _hovered = false),
      onTapUp: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              'assets/images/dialogue_box.png',
              width: width,
              height: 130,
              fit: BoxFit.fill,
              color: _hovered ? Colors.white.withValues(alpha: 0.85) : null,
              colorBlendMode: _hovered ? BlendMode.modulate : null,
            ),
            Positioned(
              top: 24,
              left: 36,
              right: 36,
              bottom: 24,
              child: Center(
                child: Text(
                  widget.choice.text,
                  textAlign: TextAlign.center,
                  style: GameTheme.bodyStyle.copyWith(
                    fontSize: 14,
                    color: Colors.white,
                    shadows: [
                      const Shadow(color: Colors.black, offset: Offset(1, 1)),
                    ],
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
