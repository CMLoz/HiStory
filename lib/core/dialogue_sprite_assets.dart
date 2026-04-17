const String bonifacioStoryKey = 'bonifacio';
const String rizalStoryKey = 'rizal';
const String lunaStoryKey = 'luna';

const Map<String, String> _mainCharacterSprites = {
  'andres bonifacio': 'assets/sprites/Bonifacio/bonifacio.png',
  'jose rizal': 'assets/sprites/Rizal/rizal.png',
  'antonio luna': 'assets/sprites/Luna/luna.png',
};

const Map<String, Map<String, String>> _storySpriteAssets = {
  bonifacioStoryKey: {
    'teodoro plata': 'assets/sprites/Bonifacio/plata.png',
    'ladislao diwa': 'assets/sprites/Bonifacio/diwa.png',
    'emilio aguinaldo': 'assets/sprites/Bonifacio/aguinaldo.png',
    'daniel tirona': 'assets/sprites/Bonifacio/tirona.png',
    'pio valenzuela': 'assets/sprites/Bonifacio/valenzuela.png',
  },
  rizalStoryKey: {
    'paciano rizal': 'assets/sprites/Rizal/paciano.png',
    'graciano lopez jaena': 'assets/sprites/Rizal/jaena.png',
    'marcelo h del pilar': 'assets/sprites/Rizal/del pilar.png',
    'mariano ponce': 'assets/sprites/Rizal/ponce.png',
    'maximo viola': 'assets/sprites/Rizal/viola.png',
    'ferdinand blumentritt': 'assets/sprites/Rizal/blumentritt.png',
    'domingo franco': 'assets/sprites/Rizal/franco.png',
  },
  lunaStoryKey: {
    'emilio aguinaldo': 'assets/sprites/Luna/aguinaldo.png',
    'aide': 'assets/sprites/Luna/npc.png',
    'soldier': 'assets/sprites/Luna/npc.png',
    'rival officer': 'assets/sprites/Luna/npc.png',
    'kawit battalion commander': 'assets/sprites/Luna/npc.png',
  },
};

String _stripPrefix(String speakerName) {
  final trimmed = speakerName.trim();
  if (trimmed.isEmpty) {
    return '';
  }

  final prefixMatch = RegExp(
    r'^(PLAYER|NPC):\s*',
    caseSensitive: false,
  ).firstMatch(trimmed);
  if (prefixMatch == null) {
    return trimmed;
  }

  return trimmed.substring(prefixMatch.end).trim();
}

String _normalizeSpeakerName(String speakerName) {
  final stripped = _stripPrefix(speakerName).toLowerCase();
  return stripped
      .replaceAll(RegExp(r'[áàâäãå]'), 'a')
      .replaceAll(RegExp(r'[éèêë]'), 'e')
      .replaceAll(RegExp(r'[íìîï]'), 'i')
      .replaceAll(RegExp(r'[óòôöõ]'), 'o')
      .replaceAll(RegExp(r'[úùûü]'), 'u')
      .replaceAll(RegExp(r'[ñ]'), 'n')
      .replaceAll(RegExp(r'[ç]'), 'c')
      .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

bool isLeftSpriteSpeaker(String speakerName) {
  final normalized = _normalizeSpeakerName(speakerName);
  return _mainCharacterSprites.containsKey(normalized);
}

String? resolveDialogueSpriteAsset({
  required String storyKey,
  required String speakerName,
}) {
  final normalized = _normalizeSpeakerName(speakerName);
  if (normalized.isEmpty || normalized == 'narrator') {
    return null;
  }

  final mainCharacterAsset = _mainCharacterSprites[normalized];
  if (mainCharacterAsset != null) {
    return mainCharacterAsset;
  }

  final storyAssets = _storySpriteAssets[storyKey];
  final storyAsset = storyAssets?[normalized];
  if (storyAsset != null) {
    return storyAsset;
  }

  if (storyKey == lunaStoryKey) {
    return 'assets/sprites/Luna/npc.png';
  }

  return null;
}

List<String> dialogueSpriteAssetsForStory(String storyKey) {
  final assets = <String>{..._mainCharacterSprites.values};
  assets.addAll(_storySpriteAssets[storyKey]?.values ?? const <String>[]);
  if (storyKey == lunaStoryKey) {
    assets.add('assets/sprites/Luna/npc.png');
  }
  return assets.toList();
}

List<String> allDialogueSpriteAssets() {
  final assets = <String>{..._mainCharacterSprites.values};
  for (final storyKey in _storySpriteAssets.keys) {
    assets.addAll(dialogueSpriteAssetsForStory(storyKey));
  }
  return assets.toList();
}

List<String> characterSelectSpriteAssets() {
  return const [
    'assets/sprites/Rizal/rizal.png',
    'assets/sprites/Bonifacio/bonifacio.png',
    'assets/sprites/Luna/luna.png',
  ];
}
