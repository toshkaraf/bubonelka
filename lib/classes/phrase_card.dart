class PhraseCard {
  String _themeNameTranslation;
  List<String> _translationPhrases;
  List<String> _germanPhrases;
  bool _isActive;
  bool _isDeleted;

  PhraseCard({
    required String themeNameTranslation,
    required List<String> translationPhrase,
    required List<String> germanPhrase,
    bool isActive = true,
    bool isDeleted = false,
  })  : _themeNameTranslation = themeNameTranslation,
        _germanPhrases = germanPhrase,
        _translationPhrases = translationPhrase,
        _isActive = isActive,
        _isDeleted = isDeleted;

  List<String> get germanPhrase => _germanPhrases;
  set germanPhrase(List<String> value) => _germanPhrases = value;

  List<String> get translationPhrase => _translationPhrases;
  set translationPhrase(List<String> value) => _translationPhrases = value;

  bool get isActive => _isActive;
  bool get isDeleted => _isDeleted; // Геттер для _isDeleted

  void toggleActive() {
    _isActive = !_isActive;
  }

  set isDeleted(bool value) => _isDeleted = value; // Сеттер для _isDeleted

  String get themeNameTranslation => _themeNameTranslation;
  set themeNameTranslation(String value) => _themeNameTranslation = value;

  void printPhraseCard() {
    print('Theme Name Translation: ${themeNameTranslation}');
    print('Translation Phrases: ${translationPhrase}');
    print('German Phrases: ${germanPhrase}');
    print('Active: ${isActive}');
    print('Deleted: ${isDeleted}'); // Вывод состояния удаления
  }
}
