class PhraseCard {
  final int? id;
  final String themeName;
  final List<String> germanPhrases;
  final List<String> translationPhrases;
  final bool isActive;
  final bool isDeleted;
  final int themeId;

  PhraseCard({
    this.id,
    required this.themeName,
    required this.germanPhrases,
    required this.translationPhrases,
    this.isActive = true,
    this.isDeleted = false,
    required this.themeId,
  });

  factory PhraseCard.fromMap(Map<String, dynamic> map) {
    return PhraseCard(
      id: map['id'],
      themeName: map['theme_name'] ?? '',
      germanPhrases: [
        (map['german_phrase1'] ?? '').toString(),
        (map['german_phrase2'] ?? '').toString(),
        (map['german_phrase3'] ?? '').toString(),
      ].where((e) => e.isNotEmpty).toList(),
      translationPhrases: [
        (map['translation_phrase1'] ?? '').toString(),
        (map['translation_phrase2'] ?? '').toString(),
        (map['translation_phrase3'] ?? '').toString(),
      ].where((e) => e.isNotEmpty).toList(),
      isActive: map['is_active'] == 1,
      isDeleted: map['is_deleted'] == 1,
      themeId: map['theme_id'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'theme_name': themeName,
      'german_phrase1': germanPhrases.isNotEmpty ? germanPhrases[0] : '',
      'german_phrase2': germanPhrases.length > 1 ? germanPhrases[1] : '',
      'german_phrase3': germanPhrases.length > 2 ? germanPhrases[2] : '',
      'translation_phrase1': translationPhrases.isNotEmpty ? translationPhrases[0] : '',
      'translation_phrase2': translationPhrases.length > 1 ? translationPhrases[1] : '',
      'translation_phrase3': translationPhrases.length > 2 ? translationPhrases[2] : '',
      'is_active': isActive ? 1 : 0,
      'is_deleted': isDeleted ? 1 : 0,
      'theme_id': themeId,
    };
  }
}
