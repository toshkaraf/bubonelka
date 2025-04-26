// phrase_card.dart (обновлённый)
import 'package:flutter_tts/flutter_tts.dart';

class PhraseCard {
  final int? id;
  final String themeName;
  final List<String> translationPhrases;
  final List<String> germanPhrases;
  final bool isActive;
  final bool isDeleted;
  final int themeId;

  bool isGermanPhrase = false;
  FlutterTts flutterTts = FlutterTts();

  PhraseCard({
    this.id,
    required this.themeName,
    required this.translationPhrases,
    required this.germanPhrases,
    this.isActive = true,
    this.isDeleted = false,
    required this.themeId,
  });

  factory PhraseCard.fromMap(Map<String, dynamic> map) {
    return PhraseCard(
      id: map['id'],
      themeName: map['theme_name'] ?? '',
      germanPhrases: [
        map['german_phrase1']?.toString() ?? '',
        map['german_phrase2']?.toString() ?? '',
        map['german_phrase3']?.toString() ?? '',
      ].where((p) => p.isNotEmpty).toList(),
      translationPhrases: [
        map['translation_phrase1']?.toString() ?? '',
        map['translation_phrase2']?.toString() ?? '',
        map['translation_phrase3']?.toString() ?? '',
      ].where((p) => p.isNotEmpty).toList(),
      isActive: map['is_active'] == 1,
      isDeleted: map['is_deleted'] == 1,
      themeId: map['theme_id'],
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

  PhraseCard copyWith({
    int? id,
    String? themeName,
    List<String>? translationPhrases,
    List<String>? germanPhrases,
    bool? isActive,
    bool? isDeleted,
    int? themeId,
  }) {
    return PhraseCard(
      id: id ?? this.id,
      themeName: themeName ?? this.themeName,
      translationPhrases: translationPhrases ?? this.translationPhrases,
      germanPhrases: germanPhrases ?? this.germanPhrases,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
      themeId: themeId ?? this.themeId,
    );
  }

  void speakSettings(String language, double speechRateTranslation) async {
    await flutterTts.setLanguage(language);
    await flutterTts.setSpeechRate(speechRateTranslation);
    await flutterTts.setPitch(1);
  }

  Future<void> speak(String phrase) async {
    await flutterTts.speak(phrase);
    await flutterTts.awaitSpeakCompletion(true);
  }

  void pauseSpeech() {
    flutterTts.pause();
  }

  void stopSpeech() {
    flutterTts.stop();
  }

  void debugPrint() {
    print('ID: \$id');
    print('Theme: \$themeName');
    print('Translation: \$translationPhrases');
    print('German: \$germanPhrases');
    print('Active: \$isActive');
    print('Deleted: \$isDeleted');
    print('Theme ID: \$themeId');
  }
}
