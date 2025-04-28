import 'dart:convert';
import 'dart:async';
import 'package:bubonelka/const_parameters.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:bubonelka/classes/phrase_card.dart';
import 'package:bubonelka/classes/theme.dart';
import 'package:flutter/services.dart';

class DatabaseHelper {
  static const _dbName = 'app_database.db';
  static const _dbVersion = 1;

  static const tableTheme = 'themes';
  static const tablePhraseCard = 'phrase_cards';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('PRAGMA foreign_keys = ON;');
        await db.execute('''
          CREATE TABLE $tableTheme (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            theme_name_translation TEXT,
            theme_name TEXT,
            file_name TEXT,
            number_of_repetition INTEGER,
            time_of_last_repetition TEXT,
            parent_id INTEGER,
            level TEXT,
            image_paths TEXT,
            position INTEGER
          );
        ''');
        await db.execute('''
          CREATE TABLE $tablePhraseCard (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            theme_name TEXT,
            german_phrase1 TEXT,
            german_phrase2 TEXT,
            german_phrase3 TEXT,
            translation_phrase1 TEXT,
            translation_phrase2 TEXT,
            translation_phrase3 TEXT,
            is_active INTEGER,
            is_deleted INTEGER,
            theme_id INTEGER,
            FOREIGN KEY (theme_id) REFERENCES $tableTheme(id) ON DELETE CASCADE
          );
        ''');
      },
    );
  }

  Future<void> loadInitialData() async {
    if (!await isInitialized()) {
      await importThemesFromCsv('assets/csv/index.csv');
    }
  }

  Future<bool> isInitialized() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $tableTheme')
    );
    return count != null && count > 0;
  }

  Future<void> importThemesFromCsv(String assetPath, {int parentId = 0}) async {
    final csvData = await rootBundle.loadString(assetPath);
    final lines = LineSplitter.split(csvData).toList();

    for (int i = 1; i < lines.length; i++) {
      final parts = lines[i].split(',');
      if (parts.length < 3) continue;

      final theme = ThemeClass(
        themeNameTranslation: parts[0].trim(),
        themeName: parts[1].trim(),
        fileName: parts[2].trim(),
        numberOfRepetition: 0,
        parentId: parentId,
        levels: parts.length > 3 ? _parseDelimited(parts[3]) : ['A'],
        imagePaths: parts.length > 4 ? _parseDelimited(parts[4]) : [],
        position: parts.length > 5 ? int.tryParse(parts[5]) ?? 0 : 0,
      );

      final themeId = await insertTheme(theme);

      if (theme.fileName.isNotEmpty && theme.fileName.endsWith('.csv')) {
        if (!theme.fileName.contains('index.csv')) {
          await importPhraseCardsFromCsv(theme.copyWith(id: themeId));
        } else {
          await importThemesFromCsv('assets/csv/${theme.fileName}', parentId: themeId);
        }
      }
    }
  }

  Future<void> importPhraseCardsFromCsv(ThemeClass theme) async {
    final csvData = await rootBundle.loadString('assets/csv/${theme.fileName}');
    final lines = LineSplitter.split(csvData).toList();
    final db = await database;
    final batch = db.batch();

    for (int i = 1; i < lines.length; i++) {
      final parts = lines[i].split(',');
      if (parts.length < 6) continue;

      final phraseCard = PhraseCard(
        themeName: theme.themeName,
        germanPhrases: parts.sublist(0, 3).map((e) => e.trim()).toList(),
        translationPhrases: parts.sublist(3, 6).map((e) => e.trim()).toList(),
        themeId: theme.id!,
      );

      batch.insert(tablePhraseCard, phraseCard.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<int> insertTheme(ThemeClass theme) async {
    final db = await database;
    return await db.insert(tableTheme, theme.toMap());
  }

  Future<ThemeClass?> getThemeByName(String themeName) async {
  final db = await database;
  final result = await db.query(
    tableTheme,
    where: 'theme_name_translation = ?', // Ищем по названию темы на русском (или другом переводе)
    whereArgs: [themeName],
  );

  if (result.isNotEmpty) {
    return ThemeClass.fromMap(result.first);
  } else {
    return null;
  }
}

  Future<List<ThemeClass>> getThemesByParentId(int parentId) async {
    final db = await database;
    final result = await db.query(tableTheme, where: 'parent_id = ?', whereArgs: [parentId], orderBy: 'position ASC');
    return result.map((e) => ThemeClass.fromMap(e)).toList();
  }

  Future<List<PhraseCard>> getPhrasesForTheme({int? themeId, String? themeName}) async {
  final db = await database;
  List<Map<String, dynamic>> result = [];

  if (themeId != null && themeId > 0) {
    result = await db.query(
      tablePhraseCard,
      where: 'theme_id = ?',
      whereArgs: [themeId],
    );
  } else if (themeName != null && themeName.isNotEmpty) {
    result = await db.query(
      tablePhraseCard,
      where: 'theme_name = ?',
      whereArgs: [themeName],
    );
  }

  return result.map((e) => PhraseCard.fromMap(e)).toList();
}

  static List<String> _parseDelimited(String raw) {
    return raw.split(RegExp(r'[;,/ ]')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  Future<void> deletePhraseFromFavorites(PhraseCard phraseCard) async {
  final db = await database;
  await db.delete(
    tablePhraseCard,
    where: 'theme_name = ? AND german_phrase1 = ? AND translation_phrase1 = ?',
    whereArgs: [
      favoritePhrasesSet,
      phraseCard.germanPhrases.isNotEmpty ? phraseCard.germanPhrases[0] : '',
      phraseCard.translationPhrases.isNotEmpty ? phraseCard.translationPhrases[0] : '',
    ],
  );
}

Future<String> loadGrammarHtml(String assetPath) async {
  try {
    return await rootBundle.loadString(assetPath);
  } catch (e) {
    return 'Не удалось загрузить справку.';
  }
}

Future<bool> hasSubthemes(int parentId) async {
  final db = await database;
  final count = Sqflite.firstIntValue(await db.rawQuery(
    'SELECT COUNT(*) FROM $tableTheme WHERE parent_id = ?', [parentId]
  ));
  return (count ?? 0) > 0;
}

  void logInfo(String message) => print('📥 $message');
  void logSuccess(String message) => print('✅ $message');
  void logError(String message) => print('❌ $message');
}
