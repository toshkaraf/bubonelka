class ThemeClass {
  final int? id;
  final String themeNameTranslation;
  final String themeName;
  final String fileName;
  final int numberOfRepetition;
  final String? timeOfLastRepetition;
  final int parentId;
  final List<String> levels;
  final List<String> imagePaths;
  final int position;

  ThemeClass({
    this.id,
    required this.themeNameTranslation,
    required this.themeName,
    required this.fileName,
    required this.numberOfRepetition,
    this.timeOfLastRepetition,
    required this.parentId,
    this.levels = const ['A'],
    this.imagePaths = const [],
    this.position = 0,
  });

  factory ThemeClass.fromMap(Map<String, dynamic> map) {
    return ThemeClass(
      id: map['id'],
      themeNameTranslation: map['theme_name_translation'] ?? '',
      themeName: map['theme_name'] ?? '',
      fileName: map['file_name'] ?? '',
      numberOfRepetition: map['number_of_repetition'] ?? 0,
      timeOfLastRepetition: map['time_of_last_repetition'],
      parentId: map['parent_id'] ?? 0,
      levels: (map['level'] as String? ?? '').split(';').where((e) => e.isNotEmpty).toList(),
      imagePaths: (map['image_paths'] as String? ?? '').split(';').where((e) => e.isNotEmpty).toList(),
      position: map['position'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'theme_name_translation': themeNameTranslation,
      'theme_name': themeName,
      'file_name': fileName,
      'number_of_repetition': numberOfRepetition,
      'time_of_last_repetition': timeOfLastRepetition,
      'parent_id': parentId,
      'level': levels.join(';'),
      'image_paths': imagePaths.join(';'),
      'position': position,
    };
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
      themeNameTranslation: themeNameTranslation ?? this.themeNameTranslation,
      themeName: themeName ?? this.themeName,
      fileName: fileName ?? this.fileName,
      numberOfRepetition: numberOfRepetition ?? this.numberOfRepetition,
      timeOfLastRepetition: timeOfLastRepetition ?? this.timeOfLastRepetition,
      parentId: parentId ?? this.parentId,
      levels: levels ?? this.levels,
      imagePaths: imagePaths ?? this.imagePaths,
      position: position ?? this.position,
    );
  }
}
