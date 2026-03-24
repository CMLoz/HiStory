import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChoiceOption {
  final String text;
  final int nextIndex;

  const ChoiceOption({required this.text, required this.nextIndex});

  factory ChoiceOption.fromJson(Map<String, dynamic> json) {
    return ChoiceOption(
      text: json['text'] as String,
      nextIndex: json['nextIndex'] as int,
    );
  }
}

class DialogueNode {
  final String speakerName;
  final String text;
  final String bgImage;
  final List<ChoiceOption>? choices;

  bool get isChoice => choices != null && choices!.isNotEmpty;

  const DialogueNode({
    required this.speakerName,
    required this.text,
    required this.bgImage,
    this.choices,
  });

  factory DialogueNode.fromJson(Map<String, dynamic> json) {
    final rawChoices = json['choices'] as List<dynamic>?;
    return DialogueNode(
      speakerName: json['speakerName'] as String? ?? '',
      text: json['text'] as String? ?? '',
      bgImage: json['bgImage'] as String? ?? '',
      choices: rawChoices
          ?.map((c) => ChoiceOption.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}

final dialogueNodesProvider = FutureProvider<List<DialogueNode>>((ref) async {
  final jsonString = await rootBundle.loadString('assets/dialogues/rizal/chapter1.json');
  final List<dynamic> jsonList = jsonDecode(jsonString);
  return jsonList.map((j) => DialogueNode.fromJson(j as Map<String, dynamic>)).toList();
});

class GameStateNotifier extends Notifier<int> {
  @override
  int build() {
    return 0; // Starts at dialogue index 0
  }

  void nextDialogue(int maxNodes) {
    if (state < maxNodes - 1) {
      state++;
    }
  }

  void jumpTo(int index) {
    state = index;
  }
}

final gameStateProvider = NotifierProvider<GameStateNotifier, int>(() {
  return GameStateNotifier();
});
