class ThemeClass {
  final int? id;
  final String themeNameTranslation;
  final String themeName;
  final String fileName;
  final int numberOfRepetition;
  final String? timeOfLastRepetition;
  final String? nextRepetitionDate; // ✅ ДОБАВЛЕНО
  final int parentId;
  final List<String> levels;
  final List<String> imagePaths;
  final int position;
  final double easeFactor; // ✅ ДОБАВЛЕНО

  ThemeClass({
    this.id,
    required this.themeNameTranslation,
    required this.themeName,
    required this.fileName,
    required this.numberOfRepetition,
    this.timeOfLastRepetition,
    this.nextRepetitionDate, // ✅ ДОБАВЛЕНО
    required this.parentId,
    this.levels = const ['A'],
    this.imagePaths = const [],
    this.position = 0,
    this.easeFactor = 2.5, // ✅ ДОБАВЛЕНО
  });

  factory ThemeClass.fromMap(Map<String, dynamic> map) {
    return ThemeClass(
      id: map['id'],
      themeNameTranslation: map['theme_name_translation'] ?? '',
      themeName: map['theme_name'] ?? '',
      fileName: map['file_name'] ?? '',
      numberOfRepetition: map['number_of_repetition'] ?? 0,
      timeOfLastRepetition: map['time_of_last_repetition'],
      nextRepetitionDate: map['next_repetition_date'], // ✅ ДОБАВЛЕНО
      parentId: map['parent_id'] ?? 0,
      levels: (map['level'] as String? ?? '').split(';').where((e) => e.isNotEmpty).toList(),
      imagePaths: (map['image_paths'] as String? ?? '').split(';').where((e) => e.isNotEmpty).toList(),
      position: map['position'] ?? 0,
      easeFactor: (map['ease_factor'] as num?)?.toDouble() ?? 2.5, // ✅ ДОБАВЛЕНО
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
      'next_repetition_date': nextRepetitionDate, // ✅ ДОБАВЛЕНО
      'parent_id': parentId,
      'level': levels.join(';'),
      'image_paths': imagePaths.join(';'),
      'position': position,
      'ease_factor': easeFactor, // ✅ ДОБАВЛЕНО
    };
  }

  ThemeClass copyWith({
    int? id,
    String? themeNameTranslation,
    String? themeName,
    String? fileName,
    int? numberOfRepetition,
    String? timeOfLastRepetition,
    String? nextRepetitionDate, // ✅ ДОБАВЛЕНО
    int? parentId,
    List<String>? levels,
    List<String>? imagePaths,
    int? position,
    double? easeFactor, // ✅ ДОБАВЛЕНО
  }) {
    return ThemeClass(
      id: id ?? this.id,
      themeNameTranslation: themeNameTranslation ?? this.themeNameTranslation,
      themeName: themeName ?? this.themeName,
      fileName: fileName ?? this.fileName,
      numberOfRepetition: numberOfRepetition ?? this.numberOfRepetition,
      timeOfLastRepetition: timeOfLastRepetition ?? this.timeOfLastRepetition,
      nextRepetitionDate: nextRepetitionDate ?? this.nextRepetitionDate, // ✅ ДОБАВЛЕНО
      parentId: parentId ?? this.parentId,
      levels: levels ?? this.levels,
      imagePaths: imagePaths ?? this.imagePaths,
      position: position ?? this.position,
      easeFactor: easeFactor ?? this.easeFactor, // ✅ ДОБАВЛЕНО
    );
  }
}

extension ThemeClassExtensions on ThemeClass {
  String get grammarFilePath {
    final topicKey = fileName.replaceAll('.csv', '');
    return 'assets/csv/${topicKey}_grammar.html';
  }

  /// Для удобства: показывает, готова ли тема к повторению
  bool get isDueForReview {
    if (nextRepetitionDate == null) return false;
    final nextDate = DateTime.tryParse(nextRepetitionDate!);
    if (nextDate == null) return false;
    return DateTime.now().isAfter(nextDate);
  }
}
