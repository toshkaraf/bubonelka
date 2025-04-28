import 'package:bubonelka/classes/phrase_card.dart';
import 'package:bubonelka/utilites/database_helper.dart';
import 'package:bubonelka/const_parameters.dart';

class CurrentPhrasesSet {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  List<PhraseCard> _currentPhrases = [];
  int _currentIndex = 0;
  bool _isInitialized = false;

  List<String> chosenThemes = [];

  PhraseCard get currentPhraseCard =>
      _currentPhrases.isNotEmpty ? _currentPhrases[_currentIndex] : emptyPhraseCard;

  Future<void> initialize(List<String> selectedThemes) async {
    if (_isInitialized) return;
    chosenThemes = selectedThemes;
    await _loadPhrases();
    _isInitialized = true;
  }

  Future<void> _loadPhrases() async {
    List<PhraseCard> all = [];
for (final themeName in chosenThemes) {
  if (themeName == favoritePhrasesSet) {
    all.addAll(await _dbHelper.getPhrasesForTheme(themeName: favoritePhrasesSet));
  } else {
    // Для обычных тем — сначала надо найти ID темы по имени
    final theme = await _dbHelper.getThemeByName(themeName);
    if (theme != null) {
      all.addAll(await _dbHelper.getPhrasesForTheme(themeId: theme.id));
    }
  }
}
    _currentPhrases = all;
    _currentIndex = 0;
  }

  PhraseCard getNextPhraseCard() {
    if (_currentPhrases.isEmpty) return emptyPhraseCard;

    if (_currentIndex < _currentPhrases.length - 1) {
      _currentIndex++;
    } else {
      return emptyPhraseCard; // Всё пройдено
    }
    return currentPhraseCard;
  }

  PhraseCard getPreviousPhraseCard() {
    if (_currentPhrases.isEmpty) return emptyPhraseCard;

    if (_currentIndex > 0) {
      _currentIndex--;
    }
    return currentPhraseCard;
  }

  bool hasMore() {
    return _currentIndex < _currentPhrases.length - 1;
  }

  void reset() {
    _currentIndex = 0;
    _isInitialized = false;
    _currentPhrases.clear();
  }
}
