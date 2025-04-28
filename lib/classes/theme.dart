class ThemeClass {
  final int? id;
  String _themeNameTranslation;
  String _themeName;
  final String fileName;
  final int numberOfRepetition;
  final String? timeOfLastRepetition;
  final int parentId;
  final List<String> levels;
  final List<String> imagePaths;
  final int position;

  ThemeClass({
    this.id,
    required String themeNameTranslation,
    required String themeName,
    required this.fileName,
    required this.numberOfRepetition,
    this.timeOfLastRepetition,
    required this.parentId,
    this.levels = const ['A'],
    this.imagePaths = const [],
    this.position = 0,
  })  : _themeNameTranslation = themeNameTranslation,
        _themeName = themeName;

  // Геттеры
  String get themeNameTranslation => _themeNameTranslation;
  String get themeName => _themeName;

  // Сеттеры
  set themeNameTranslation(String value) {
    _themeNameTranslation = value;
  }

  set themeName(String value) {
    _themeName = value;
  }

  // Геттер для пути к грамматическому файлу
  String get computedGrammarFilePath {
    final topicKey = fileName.replaceAll('.csv', '');
    return 'assets/csv/${topicKey}_grammar.html';
  }

  // Геттер для пути к папке изображений
  String get computedImageFolderPath {
    final topicKey = fileName.replaceAll('.csv', '');
    return 'assets/csv/${topicKey}_img';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'theme_name_translation': _themeNameTranslation,
      'theme_name': _themeName,
      'file_name': fileName,
      'number_of_repetition': numberOfRepetition,
      'time_of_last_repetition': timeOfLastRepetition,
      'parent_id': parentId,
      'level': levels.join(';'),
      'image_paths': imagePaths.join(';'),
      'position': position,
    };
  }

  factory ThemeClass.fromMap(Map<String, dynamic> map) {
    return ThemeClass(
      id: map['id'],
      themeNameTranslation: map['theme_name_translation'] ?? '',
      themeName: map['theme_name'] ?? '',
      fileName: map['file_name'] ?? '',
      numberOfRepetition: map['number_of_repetition'] ?? 0,
      timeOfLastRepetition: map['time_of_last_repetition'],
      parentId: map['parent_id'] ?? 0,
      levels: _parseLevels(map['level']),
      imagePaths: _parseDelimitedList(map['image_paths']),
      position: map['position'] ?? 0,
    );
  }

  ThemeClass copyWith({
    int? id,
    String? themeNameTranslation,
    String? themeName,
    String? fileName,
    int? numberOfRepetition,
    String? timeOfLastRepetition,
    int? parentId,
    List<String>? levels,
    List<String>? imagePaths,
    int? position,
  }) {
    return ThemeClass(
      id: id ?? this.id,
      themeNameTranslation: themeNameTranslation ?? this._themeNameTranslation,
      themeName: themeName ?? this._themeName,
      fileName: fileName ?? this.fileName,
      numberOfRepetition: numberOfRepetition ?? this.numberOfRepetition,
      timeOfLastRepetition: timeOfLastRepetition ?? this.timeOfLastRepetition,
      parentId: parentId ?? this.parentId,
      levels: levels ?? this.levels,
      imagePaths: imagePaths ?? this.imagePaths,
      position: position ?? this.position,
    );
  }

  static List<String> _parseLevels(dynamic raw) {
    final str = (raw as String?) ?? 'A';
    return str
        .split(RegExp(r'[;,/ ]'))
        .map((e) => e.trim().toUpperCase())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
  }

  static List<String> _parseDelimitedList(dynamic raw) {
    final str = (raw as String?) ?? '';
    return str
        .split(';')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
}
