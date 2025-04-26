import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:bubonelka/classes/phrase_card.dart';
import 'package:bubonelka/classes/theme.dart';
import 'package:bubonelka/const_parameters.dart';

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
            position INTEGER,
            folder TEXT
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
            FOREIGN KEY (theme_id) REFERENCES $tableTheme(id)
          );
        ''');
      },
    );
  }

  Future<void> loadInitialData() async {
    await importThemesFromCsv('assets/csv/index.csv');
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
    final folder = _extractFolderFromPath(assetPath);

    for (int i = 1; i < lines.length; i++) {
      final parts = lines[i].split(',');
      if (parts.length < 3) continue;

      logInfo('Загружаю тему: ${parts[1].trim()} из файла: ${parts[2].trim()}');

      final fileName = parts[2].trim();
      String themeSubfolder = folder;

      if (fileName.contains('/') && fileName.endsWith('index.csv')) {
        final subfolder = fileName.split('/').first;
        themeSubfolder = '$folder/$subfolder';
      }

      final theme = ThemeClass(
        themeNameTranslation: parts[0].trim(),
        themeName: parts[1].trim(),
        fileName: fileName,
        numberOfRepetition: 0,
        timeOfLastRepetition: null,
        parentId: parentId,
        levels: parts.length > 3 ? _parseLevels(parts[3]) : ['A'],
        imagePaths: [],
        position: parts.length > 4 ? int.tryParse(parts[4].trim()) ?? 0 : 0,
        folder: themeSubfolder,
      );

      final themeId = await insertTheme(theme);

      if (theme.fileName.isNotEmpty && theme.fileName.endsWith('.csv')) {
        final nestedPath = _buildAssetPath(theme);
        if (theme.fileName.endsWith('index.csv')) {
          await importThemesFromCsv(nestedPath, parentId: themeId);
        } else {
          await importPhraseCardsFromCsv(theme.copyWith(id: themeId));
        }
      }
    }
  }

  Future<void> importPhraseCardsFromCsv(ThemeClass theme) async {
    final phraseCardsPath = _buildAssetPath(theme);
    final csvData = await rootBundle.loadString(phraseCardsPath);
    final lines = LineSplitter.split(csvData).toList();

    for (int i = 1; i < lines.length; i++) {
      final parts = lines[i].split(',');
      if (parts.length < 6) continue;

      final phraseCard = PhraseCard(
        themeName: theme.themeName,
        germanPhrases: parts.sublist(0, 3).map((e) => e.trim()).toList(),
        translationPhrases: parts.sublist(3, 6).map((e) => e.trim()).toList(),
        isActive: true,
        isDeleted: false,
        themeId: theme.id ?? 0,
      );

      await insertPhraseCard(phraseCard);
    }

    logSuccess('Фразы загружены из: ${theme.folder}/${theme.fileName}');
  }

  Future<int> insertTheme(ThemeClass theme) async {
    final db = await database;
    final id = await db.insert(tableTheme, theme.toMap());
    logSuccess('Тема добавлена: ${theme.folder}/${theme.fileName} (id=$id)');
    return id;
  }

  Future<int> insertPhraseCard(PhraseCard phraseCard) async {
    final db = await database;
    return await db.insert(tablePhraseCard, phraseCard.toMap());
  }

  Future<List<ThemeClass>> getAllThemes() async {
    final db = await database;
    final result = await db.query(tableTheme, orderBy: 'position ASC');
    return result.map((e) => ThemeClass.fromMap(e)).toList();
  }

  Future<List<ThemeClass>> getThemesByParentId(int parentId) async {
    final db = await database;
    final result = await db.query(
      tableTheme,
      where: 'parent_id = ?',
      whereArgs: [parentId],
      orderBy: 'position ASC',
    );
    return result.map((e) => ThemeClass.fromMap(e)).toList();
  }

  Future<List<PhraseCard>> getPhrasesByThemeId(int themeId) async {
    final db = await database;
    final result = await db.query(
      tablePhraseCard,
      where: 'theme_id = ?',
      whereArgs: [themeId],
    );
    return result.map((e) => PhraseCard.fromMap(e)).toList();
  }

  Future<List<PhraseCard>> getPhrasesByThemeName(String themeName) async {
    final db = await database;
    final result = await db.query(
      tablePhraseCard,
      where: 'theme_name = ?',
      whereArgs: [themeName],
    );
    return result.map((e) => PhraseCard.fromMap(e)).toList();
  }

  Future<void> addToFavorites(PhraseCard phraseCard) async {
    final db = await database;
    final existing = await db.query(
      tablePhraseCard,
      where: 'theme_name = ? AND german_phrase1 = ? AND translation_phrase1 = ?',
      whereArgs: [
        favoritePhrasesSet,
        phraseCard.germanPhrases.isNotEmpty ? phraseCard.germanPhrases[0] : '',
        phraseCard.translationPhrases.isNotEmpty ? phraseCard.translationPhrases[0] : '',
      ],
    );
    if (existing.isEmpty) {
      final newCard = phraseCard.copyWith(
        themeName: favoritePhrasesSet,
        themeId: -1,
      );
      await db.insert(tablePhraseCard, newCard.toMap());
    }
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

  String _extractFolderFromPath(String path) {
    final parts = path.split('/');
    if (parts.length >= 3) {
      return parts[parts.length - 2];
    }
    return 'csv';
  }

  static List<String> _parseLevels(String raw) {
    return raw
        .split(RegExp(r'[;,/ ]'))
        .map((e) => e.trim().toUpperCase())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  String _buildAssetPath(ThemeClass theme) {
    if (theme.fileName.endsWith('index.csv')) {
      return 'assets/csv/${theme.fileName}';
    } else {
      final baseFolder = (theme.folder == 'csv') ? '' : '${theme.folder}/';
      return 'assets/csv/$baseFolder${theme.fileName}';
    }
  }

  // 🚀 Красивые логи:
  void logInfo(String message) {
    print('📥 $message');
  }

  void logSuccess(String message) {
    print('✅ $message');
  }

  void logError(String message) {
    print('❌ $message');
  }
}
