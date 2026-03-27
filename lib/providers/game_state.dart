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
  final String? sceneId;

  bool get isChoice => choices != null && choices!.isNotEmpty;

  const DialogueNode({
    required this.speakerName,
    required this.text,
    required this.bgImage,
    this.choices,
    this.sceneId,
  });

  factory DialogueNode.fromJson(Map<String, dynamic> json, {String? sceneId}) {
    final rawChoices = json['choices'] as List<dynamic>?;
    return DialogueNode(
      speakerName: json['speakerName'] as String? ?? '',
      text: json['text'] as String? ?? '',
      bgImage: json['bgImage'] as String? ?? '',
      choices: rawChoices
          ?.map((c) => ChoiceOption.fromJson(c as Map<String, dynamic>))
          .toList(),
      sceneId: sceneId ?? json['sceneId'] as String?,
    );
  }
}

class Chapter {
  final String id;
  final String title;
  final List<DialogueNode> nodes;

  const Chapter({required this.id, required this.title, required this.nodes});

  factory Chapter.fromJson(
    Map<String, dynamic> json, {
    List<DialogueNode>? nodes,
  }) {
    // If nodes are passed (legacy), use them.
    if (nodes != null) {
      return Chapter(id: "legacy", title: "Legacy", nodes: nodes);
    }

    // Parse from JSON
    final List<DialogueNode> allNodes = [];
    final scenes = json['scenes'] as List<dynamic>? ?? [];

    for (var scene in scenes) {
      final String sceneId = scene['id'] as String? ?? '';
      final List<dynamic> dialogues =
          scene['dialogues'] as List<dynamic>? ?? [];

      for (var d in dialogues) {
        allNodes.add(
          DialogueNode.fromJson(d as Map<String, dynamic>, sceneId: sceneId),
        );
      }
    }

    return Chapter(
      id: json['chapterId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      nodes: allNodes,
    );
  }
}

final currentChapterProvider = NotifierProvider<CurrentChapterNotifier, String>(
  CurrentChapterNotifier.new,
);

class CurrentChapterNotifier extends Notifier<String> {
  @override
  String build() {
    return 'chapter1';
  }

  void nextChapter() {
    if (state == 'chapter1') {
      state = 'chapter2';
    } else if (state == 'chapter2') {
      state = 'chapter3';
    }
    // Extend logic for future chapters
  }
}

final dialogueNodesProvider = FutureProvider<Chapter>((ref) async {
  final chapterId = ref.watch(currentChapterProvider);
  final jsonString = await rootBundle.loadString(
    'assets/dialogues/rizal/$chapterId.json',
  );
  final dynamic jsonData = jsonDecode(jsonString);

  if (jsonData is List) {
    // Legacy support for flat list
    final nodes = jsonData
        .map((j) => DialogueNode.fromJson(j as Map<String, dynamic>))
        .toList();
    return Chapter(id: "legacy", title: "Legacy", nodes: nodes);
  } else if (jsonData is Map<String, dynamic>) {
    return Chapter.fromJson(jsonData);
  }
  return const Chapter(id: "error", title: "Error", nodes: []);
});

class GameStateNotifier extends Notifier<int> {
  @override
  int build() {
    return 0; // Starts at dialogue index 0
  }

  void reset() {
    state = 0;
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
