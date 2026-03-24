import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Text speed is stored as milliseconds per character.
/// Slow = 60ms, Normal = 30ms, Fast = 10ms
class TextSpeedNotifier extends Notifier<int> {
  @override
  int build() => 30; // Default: normal speed

  void setSpeed(int msPerChar) {
    state = msPerChar;
  }
}

final textSpeedProvider = NotifierProvider<TextSpeedNotifier, int>(() {
  return TextSpeedNotifier();
});
