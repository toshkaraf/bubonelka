import 'package:flutter/material.dart';

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

extension ThemeStage on ThemeClass {
  int get currentStage {
    if (timeOfLastRepetition == null) return 0; // Новая тема, ещё не изучали

    if (nextRepetitionDate == null) return 0;
    final nextDate = DateTime.tryParse(nextRepetitionDate!);
    if (nextDate == null) return 0;

    final now = DateTime.now();
    final diffMinutes = nextDate.difference(now).inMinutes;

    if (diffMinutes <= 180) return 1;           // до 3 часов
    if (diffMinutes <= 420) return 2;           // 3–7 часов
    if (diffMinutes <= 1440) return 3;          // 7–24 часов (1 день)
    if (diffMinutes <= 4320) return 4;          // 1–3 дней
    if (diffMinutes <= 8640) return 5;          // 3–6 дней
    return 6; // Полностью усвоено (>6 дней)
  }
}

extension ThemeStageColors on ThemeClass {
  Color get stageColor {
    switch (currentStage) {
      case 0:
        return Colors.blueAccent;
      case 1:
        return Colors.red;
      case 2:
        return Colors.deepOrange;
      case 3:
        return Colors.amber;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      case 6:
        return Colors.green.shade900;
      default:
        return Colors.blueAccent;
    }
  }
}

extension TimeFormatExtension on int {
  String toCompactTime() {
    if (this < 60) {
      return '$this мин';
    } else if (this < 1440) {
      final hours = (this / 60).round();
      return '$hours ч';
    } else {
      final days = (this / 1440).round();
      return '$days д';
    }
  }
}

extension ThemePredictedInterval on ThemeClass {
  int predictNextIntervalMinutes(int rating) {
    final multipliers = {
      1: 0.5,
      2: 0.7,
      3: 1.0,
      4: 1.3,
      5: 1.7,
    };

    bool isFirstRepetition = timeOfLastRepetition == null;
    double currentEaseFactor = easeFactor;
    double newEaseFactor = currentEaseFactor +
        (0.1 - (5 - rating) * (0.08 + (5 - rating) * 0.02));

    if (newEaseFactor < 1.3) newEaseFactor = 1.3;
    if (newEaseFactor > 3.0) newEaseFactor = 3.0;

    if (isFirstRepetition) {
      switch (rating) {
        case 1:
          return 10;
        case 2:
          return 60;
        case 3:
          return 1440;
        case 4:
          return 2880;
        case 5:
          return 4320;
        default:
          return 1440;
      }
    } else {
      int previousIntervalMinutes = 1440;

      if (timeOfLastRepetition != null && nextRepetitionDate != null) {
        final lastDate = DateTime.tryParse(timeOfLastRepetition!);
        final nextDate = DateTime.tryParse(nextRepetitionDate!);
        if (lastDate != null && nextDate != null) {
          previousIntervalMinutes =
              nextDate.difference(lastDate).inMinutes;
          if (previousIntervalMinutes < 1) previousIntervalMinutes = 1;
        }
      }

      final multiplier = multipliers[rating] ?? 1.0;
      int predicted = (previousIntervalMinutes * newEaseFactor * multiplier).round();
      return predicted < 1 ? 1 : predicted;
    }
  }
}


