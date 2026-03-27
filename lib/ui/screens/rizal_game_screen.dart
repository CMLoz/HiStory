import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:history/providers/game_state.dart';
import 'package:history/providers/settings_provider.dart';
import 'package:history/ui/theme/game_theme.dart';
import 'package:history/ui/widgets/audio_image_button.dart';
import 'package:history/ui/widgets/typewriter_text.dart';
import 'package:history/ui/screens/main_menu_screen.dart';
import 'package:history/ui/screens/options_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class RizalGameScreen extends ConsumerStatefulWidget {
  const RizalGameScreen({super.key});

  @override
  ConsumerState<RizalGameScreen> createState() => _RizalGameScreenState();
}

class _RizalGameScreenState extends ConsumerState<RizalGameScreen> {
  // Game Screen Opacity (for scene transitions)
  double _opacity = 0.0;
  Duration _opacityDuration = const Duration(seconds: 2);

  bool _assetsLoaded = false;
  bool _sceneAssetsLoaded = false;
  bool _isPaused = false;

  // Controls which node is currently displayed
  int? _displayIndex;

  // Chapter Title Screen State
  bool _showChapterTitle = true; // Start with title screen by default
  double _titleOpacity = 0.0;

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
  }

  void _preloadSceneAssets(Chapter chapter) {
    if (_sceneAssetsLoaded || !mounted) return;

    final uniqueImages = chapter.nodes.map((n) => n.bgImage).toSet();
    for (var imgPath in uniqueImages) {
      if (imgPath.isNotEmpty && mounted) {
        precacheImage(AssetImage(imgPath), context);
      }
    }
    _sceneAssetsLoaded = true;
  }

  void _startChapterSequence() {
    // 1. Fade in Title
    setState(() {
      _titleOpacity = 1.0;
    });

    // 2. Wait, then Fade out Title
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _titleOpacity = 0.0;
        });

        // 3. Wait for fade out, then hide title screen and fade in scene
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _showChapterTitle = false;
              // Reset game opacity to 0 before showing scene
              _opacity = 0.0;
            });

            // 4. Fade in Scene
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) {
                setState(() {
                  _opacity = 1.0;
                });
              }
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncChapter = ref.watch(dialogueNodesProvider);
    final GameStateNotifier gameNotifier = ref.read(gameStateProvider.notifier);
    final int textSpeedMs = ref.watch(textSpeedProvider);

    // Listen to game state changes for scene transitions (intra-chapter)
    ref.listen<int>(gameStateProvider, (previous, next) {
      if (asyncChapter.hasValue && !_showChapterTitle) {
        final nodes = asyncChapter.value!.nodes;
        // Ensure indices are valid
        if (previous != null &&
            previous < nodes.length &&
            next < nodes.length) {
          final prevNode = nodes[previous];
          final nextNode = nodes[next];

          // Check if scene changed
          final bool sceneChanged =
              (prevNode.sceneId != null && nextNode.sceneId != null)
              ? prevNode.sceneId != nextNode.sceneId
              : prevNode.bgImage != nextNode.bgImage;

          if (sceneChanged) {
            // Scene Transition: Fade Out -> Update -> Fade In
            setState(() {
              _opacity = 0.0;
              _opacityDuration = const Duration(milliseconds: 1500);
            });

            Future.delayed(const Duration(milliseconds: 1500), () {
              if (mounted) {
                setState(() {
                  _displayIndex = next;
                });

                Future.delayed(const Duration(milliseconds: 100), () {
                  if (mounted) {
                    setState(() {
                      _opacity = 1.0;
                    });
                  }
                });
              }
            });
          } else {
            // Instant update
            setState(() {
              _displayIndex = next;
            });
          }
        } else {
          setState(() {
            _displayIndex = next;
          });
        }
      }
    });

    // Listen for Chapter changes to reset sequence
    ref.listen(dialogueNodesProvider, (prev, next) {
      if (next is AsyncData) {
        // New chapter loaded

        setState(() {
          _showChapterTitle = true;
          _titleOpacity = 0.0;
          _opacity = 0.0;
          _displayIndex = 0; // Reset index for new chapter
          _sceneAssetsLoaded = false; // Trigger asset reload
        });

        gameNotifier
            .reset(); // Reset global game state index after setting title flag

        // Start the sequence for the new chapter
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _startChapterSequence();
        });
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: asyncChapter.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.amber)),
        error: (error, stack) => Center(
          child: Text(
            'Error loading chapter: $error',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        data: (chapter) {
          final nodes = chapter.nodes;

          // Sync initial index safely
          if (_displayIndex == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _displayIndex = ref.read(gameStateProvider);
                });
                // Start the very first chapter sequence if it hasn't run
                if (_showChapterTitle) {
                  _startChapterSequence();
                }
              }
            });
            return const SizedBox.shrink();
          }

          if (!_sceneAssetsLoaded) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _preloadSceneAssets(chapter);
            });
          }

          // --- CHAPTER TITLE SCREEN ---
          if (_showChapterTitle) {
            final String chapterId = ref.read(currentChapterProvider);
            final String chapterLabel = chapterId.replaceAll('chapter', 'CHAPTER ');
            
            return Container(
              color: Colors.black,
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: AnimatedOpacity(
                  opacity: _titleOpacity,
                  duration: const Duration(seconds: 2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        chapterLabel.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cinzelDecorative(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                          letterSpacing: 8.0,
                          shadows: [
                            const Shadow(
                              color: Colors.amber,
                              blurRadius: 20,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        chapter.title.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cinzel(
                          fontSize: 20,
                          color: Colors.white70,
                          letterSpacing: 4.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // --- GAME SCENE ---
          // Safety check for index
          if (_displayIndex! >= nodes.length) {
            return const SizedBox.shrink();
          }

          final DialogueNode currentNode = nodes[_displayIndex!];
          final bool isChoice = currentNode.isChoice;
          final bool isLastNode = _displayIndex == nodes.length - 1;

          return GestureDetector(
            onTap: isChoice || _isPaused || _showChapterTitle || _opacity != 1.0
                ? null
                : () {
                    // Typewriter finish logic
                    if (_typewriterKey.currentState?.isFinished == false) {
                      _typewriterKey.currentState?.completeText();
                    } else {
                      if (isLastNode) {
                        // --- END OF CHAPTER LOGIC ---
                        setState(() {
                          _opacity = 0.0;
                          _opacityDuration = const Duration(milliseconds: 1500);
                        });

                        Future.delayed(const Duration(milliseconds: 1500), () {
                          if (mounted) {
                            // Proceed to next chapter
                            ref
                                .read(currentChapterProvider.notifier)
                                .nextChapter();
                            // Reset state handled by ref.listen above
                          }
                        });
                      } else {
                        // Next dialogue
                        gameNotifier.nextDialogue(nodes.length);
                      }
                    }
                  },
            child: AnimatedOpacity(
              opacity: _opacity,
              duration: _opacityDuration,
              child: Stack(
                children: [
                  // Background Image
                  Positioned.fill(
                    child: Image.asset(
                      currentNode.bgImage,
                      key: ValueKey<String>(currentNode.bgImage),
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
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
