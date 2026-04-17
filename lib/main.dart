import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:history/core/dialogue_sprite_assets.dart';
import 'package:history/ui/screens/main_menu_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set orientation to landscape
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Preload audio files so they decode immediately
  await FlameAudio.audioCache.loadAll(['main-theme.mp3', 'button-click.mp3']);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache shared background and main menu buttons
    precacheImage(
      const AssetImage('assets/images/pixel_art_large.png'),
      context,
    );
    precacheImage(const AssetImage('assets/images/Play Button.png'), context);
    precacheImage(
      const AssetImage('assets/images/Options Button.png'),
      context,
    );
    precacheImage(const AssetImage('assets/images/Quit Button.png'), context);

    // Precache character select screen assets
    precacheImage(
      const AssetImage('assets/images/Back Square Button.png'),
      context,
    );
    precacheImage(
      const AssetImage('assets/images/rizal_nameplate.png'),
      context,
    );
    precacheImage(
      const AssetImage('assets/images/boni_nameplate.png'),
      context,
    );
    precacheImage(
      const AssetImage('assets/images/luna_nameplate.png'),
      context,
    );

    for (final assetPath in allDialogueSpriteAssets()) {
      precacheImage(AssetImage(assetPath), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HiStory Visual Novel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Enhance visual novel feel
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark, // Often preferred for VN/Games
        ),
        useMaterial3: true,
      ),
      home: const MainMenuScreen(),
    );
  }
}
