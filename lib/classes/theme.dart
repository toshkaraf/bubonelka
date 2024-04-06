class ThemeClass {
  String _themeNameTranslation;
  String _themeName;
  int _numberOfRepetition;
  DateTime? _timeOfLastRepetition;

  ThemeClass({
    required String themeNameTranslation,
    required String themeName,
    required int numberOfRepetition,
    DateTime? timeOfLastRepetition,
  })  : _themeNameTranslation = themeNameTranslation,
        _themeName = themeName,
        _numberOfRepetition = numberOfRepetition,
        _timeOfLastRepetition = timeOfLastRepetition;

  String get themeName => _themeName;
  set themeName(String value) => _themeName = value;

  String get themeNameTranslation => _themeNameTranslation;
  set themeNameTranslation(String value) => _themeNameTranslation = value;

  int get numberOfRepetition => _numberOfRepetition;
  set numberOfRepetition(int value) => _numberOfRepetition = value;

  DateTime? get timeOfLastRepetition => _timeOfLastRepetition;
  set timeOfLastRepetition(DateTime? value) => _timeOfLastRepetition = value;
}
