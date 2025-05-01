import 'package:shared_preferences/shared_preferences.dart';
import 'package:bubonelka/const_parameters.dart';

class SettingsAndState {
  static final SettingsAndState _instance = SettingsAndState._internal();

  String _currentThemeName = '';
  List<String> _chosenThemes = [];

  // Новые настройки
  double _speechRateBase = speechRateTranslation;
  int _delayBeforeGerman = delayBeforGermanPhraseInSeconds;

  SettingsAndState._internal();

  static SettingsAndState getInstance() => _instance;

  String get currentThemeName => _currentThemeName;
  List<String> get chosenThemes => _chosenThemes;

  double get speechRateBase => _speechRateBase;
  int get delayBeforeGerman => _delayBeforeGerman;

  set currentThemeName(String themeName) {
    _currentThemeName = themeName;
  }

  set chosenThemes(List<String> themes) {
    _chosenThemes = themes;
    if (themes.isNotEmpty) {
      _currentThemeName = themes.first;
    }
  }

  void resetChosenThemes() {
    _chosenThemes = [];
    _currentThemeName = '';
  }

  bool isFavoriteSelected() {
    return _chosenThemes.length == 1 && _chosenThemes.first == favoritePhrasesSet;
  }

  Future<void> setSpeechRateBase(double rate) async {
    _speechRateBase = rate;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('speechRateBase', rate);
  }

  Future<void> setDelayBeforeGerman(int seconds) async {
    _delayBeforeGerman = seconds;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('delayBeforeGerman', seconds);
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _speechRateBase =
        prefs.getDouble('speechRateBase') ?? speechRateTranslation;
    _delayBeforeGerman =
        prefs.getInt('delayBeforeGerman') ?? delayBeforGermanPhraseInSeconds;
  }
}
