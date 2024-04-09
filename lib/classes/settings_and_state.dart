import 'package:bubonelka/classes/collection_provider.dart';

class SettingsAndState {
  static final SettingsAndState _instance = SettingsAndState._internal();
  String _currentThemeName = CollectionProvider.getInstance().getListOfThemesNames()[0];
  List<String> _themeList = [];

  SettingsAndState._internal();

  String get currentThemeName => _currentThemeName;

  set currentThemeName(String currentThemeName) {
    _currentThemeName = currentThemeName;
  }

  List<String> get themeList => _themeList;

  set themeList(List<String> themeList) {
    _themeList = themeList;
  }

  static SettingsAndState getInstance() {
    return _instance;
  }
}
