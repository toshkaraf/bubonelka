class SettingsAndState {
  static final SettingsAndState _instance = SettingsAndState._internal();
  String _currentDictionaryName = '';
  List<String> _themeList = [];

  SettingsAndState._internal();

  String get currentThemeName => _currentDictionaryName;

  set currentThemeName(String currentThemeName) {
    _currentDictionaryName = currentThemeName;
  }

  List<String> get themeList => _themeList;

  set themeList(List<String> themeList) {
    _themeList = themeList;
  }

  static SettingsAndState getInstance() {
    return _instance;
  }
}
