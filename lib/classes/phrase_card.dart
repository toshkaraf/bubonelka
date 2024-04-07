class PhraseCard {
  String _themeNameTranslation;
  List<String> _translationPhrases;
  List<String> _germanPhrases;

  PhraseCard({
    required String themeNameTranslation,
    required List<String> translationPhrase,
    required List<String> germanPhrase,
  })  : _themeNameTranslation = themeNameTranslation,
        _germanPhrases = germanPhrase,
        _translationPhrases = translationPhrase;

  List<String> get germanPhrase => _germanPhrases;
  set germanPhrase(List<String> value) => _germanPhrases = value;

  List<String> get translationPhrase => _translationPhrases;
  set translationPhrase(List<String> value) => _translationPhrases = value;

  // Добавленные методы для доступа к полям извне класса
  String get themeNameTranslation => _themeNameTranslation;
  set themeNameTranslation(String value) => _themeNameTranslation = value;

  void printPhraseCard() {
  print('Theme Name Translation: ${themeNameTranslation}');
  print('Translation Phrases: ${translationPhrase}');
  print('German Phrases: ${germanPhrase}');
}
}
