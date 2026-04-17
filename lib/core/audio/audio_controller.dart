import 'package:flame_audio/flame_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// State class to hold audio preferences
class AudioSettings {
  final bool isBgmEnabled;
  final bool isSfxEnabled;
  final double bgmVolume;
  final double sfxVolume;

  const AudioSettings({
    this.isBgmEnabled = true,
    this.isSfxEnabled = true,
    this.bgmVolume = 0.2,
    this.sfxVolume = 1.0,
  });

  AudioSettings copyWith({
    bool? isBgmEnabled,
    bool? isSfxEnabled,
    double? bgmVolume,
    double? sfxVolume,
  }) {
    return AudioSettings(
      isBgmEnabled: isBgmEnabled ?? this.isBgmEnabled,
      isSfxEnabled: isSfxEnabled ?? this.isSfxEnabled,
      bgmVolume: bgmVolume ?? this.bgmVolume,
      sfxVolume: sfxVolume ?? this.sfxVolume,
    );
  }
}

class AudioController extends Notifier<AudioSettings> {
  @override
  AudioSettings build() {
    return const AudioSettings();
  }

  void toggleBgm(bool enabled) {
    state = state.copyWith(isBgmEnabled: enabled);
    if (enabled) {
      FlameAudio.bgm.play('main-theme.mp3', volume: state.bgmVolume);
    } else {
      FlameAudio.bgm.stop();
    }
  }

  void toggleSfx(bool enabled) {
    state = state.copyWith(isSfxEnabled: enabled);
  }

  void setBgmVolume(double volume) {
    state = state.copyWith(bgmVolume: volume);
    // Setting volume on audio player instance directly without restarting track
    if (state.isBgmEnabled) {
      FlameAudio.bgm.audioPlayer.setVolume(volume);
    }
  }

  void setSfxVolume(double volume) {
    state = state.copyWith(sfxVolume: volume);
  }

  void playSfx(String filename) {
    if (state.isSfxEnabled) {
      FlameAudio.play(filename, volume: state.sfxVolume);
    }
  }

  Future<void> preloadSfx(List<String> filenames) async {
    await FlameAudio.audioCache.loadAll(filenames);
  }

  Future<void> preloadBgm(List<String> filenames) async {
    await FlameAudio.audioCache.loadAll(filenames);
  }

  void startBgm() {
    if (state.isBgmEnabled) {
      FlameAudio.bgm.play('main-theme.mp3', volume: state.bgmVolume);
    }
  }

  void stopBgm() {
    FlameAudio.bgm.stop();
  }
}

final audioControllerProvider =
    NotifierProvider<AudioController, AudioSettings>(AudioController.new);
