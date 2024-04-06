class SettingsAndState {
  // Статическое поле для хранения единственного экземпляра класса
  static final SettingsAndState _instance = SettingsAndState._internal();

  // Пустая переменная themeList типа List<String>
  List<String> themeList = [];

  // Приватный конструктор
  SettingsAndState._internal();

  // Статический метод для получения экземпляра класса
  static SettingsAndState getInstance() {
    return _instance;
  }
}