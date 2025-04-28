import 'package:bubonelka/const_parameters.dart';
import 'package:bubonelka/rutes.dart';

class SettingsAndState {
  static final SettingsAndState _instance = SettingsAndState._internal();

  String _currentThemeName = '';
  List<String> _chosenThemes = [];

  SettingsAndState._internal();

  static SettingsAndState getInstance() => _instance;

  String get currentThemeName => _currentThemeName;

  set currentThemeName(String themeName) {
    _currentThemeName = themeName;
  }

  List<String> get chosenThemes => _chosenThemes;

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
    return _chosenThemes.length == 1 && _chosenThemes.first == favoritePhrasesPage;
  }
}
