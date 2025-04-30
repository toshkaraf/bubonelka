import 'dart:convert';
import 'dart:async';
import 'package:bubonelka/const_parameters.dart';
import 'package:csv/csv.dart';
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
  final List<List<dynamic>> csvTable = const CsvToListConverter(
    fieldDelimiter: ';', // точка с запятой
    eol: '\n',
  ).convert(csvData);

  print('📥 ====== CSV CONTENT FOR $assetPath ======');
  for (int i = 0; i < csvTable.length; i++) {
    print('📥 Line $i: ${csvTable[i].join(';')}');
  }
  print('📥 ======================================');

  for (int i = 1; i < csvTable.length; i++) {
    final parts = csvTable[i].map((e) => e.toString().trim()).toList();

    if (parts.length < 3) {
      logError('❌ Ошибка в строке CSV: недостаточно данных: $parts');
      continue;
    }

    int position = i;
    if (parts.length > 4) {
      final parsed = int.tryParse(parts[4]);
      if (parsed != null) {
        position = parsed;
        print('📥 Parsed position: $position for theme: ${parts[1]}');
      } else {
        logError('❌ Error parsing position for ${parts[1]}: ${parts[4]}');
      }
    }

    final theme = ThemeClass(
      themeNameTranslation: parts[0],
      themeName: parts[1],
      fileName: parts[2],
      numberOfRepetition: 0,
      parentId: parentId,
      levels: parts.length > 3 ? _parseDelimited(parts[3]) : ['A'],
      imagePaths: [],
      position: position,
    );

    final themeId = await insertTheme(theme);
    logInfo('📥 Importing theme: ${theme.themeName} with position: ${theme.position}');

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
  final List<List<dynamic>> csvTable = const CsvToListConverter(
    fieldDelimiter: ';', // точка с запятой
    eol: '\n',
  ).convert(csvData);

  print('📥 ====== PHRASES CSV FOR ${theme.themeName} ======');
  for (int i = 0; i < csvTable.length; i++) {
    print('📥 Line $i: ${csvTable[i].join(';')}');
  }
  print('📥 ======================================');

  final db = await database;
  final batch = db.batch();

  for (int i = 1; i < csvTable.length; i++) {
    final parts = csvTable[i].map((e) => e.toString().trim()).toList();

    if (parts.length < 6) {
      logError('❌ Ошибка в строке фраз CSV: недостаточно данных: $parts');
      continue;
    }

    final phraseCard = PhraseCard(
      themeName: theme.themeName,
      germanPhrases: parts.sublist(0, 3),
      translationPhrases: parts.sublist(3, 6),
      themeId: theme.id!,
    );

    batch.insert(tablePhraseCard, phraseCard.toMap());
  }

  await batch.commit(noResult: true);
  logSuccess('✅ Фразы загружены для темы: ${theme.themeNameTranslation}');
}


  Future<List<ThemeClass>> getThemesByParentId(int parentId) async {
    final db = await database;
    final result = await db.query(
      tableTheme, 
      where: 'parent_id = ?', 
      whereArgs: [parentId], 
      orderBy: 'position ASC'
    );
    
    final themes = result.map((e) => ThemeClass.fromMap(e)).toList();
    
    // Логируем для отладки
    logInfo('=== Themes for parent $parentId (ordered by position) ===');
    for (var theme in themes) {
      logInfo('${theme.themeName}: position = ${theme.position}');
    }
    
    return themes;
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

  Future<List<ThemeClass>> getAllThemes() async {
    final db = await database;
    final result = await db.query(tableTheme);
    final themes = result.map((e) => ThemeClass.fromMap(e)).toList();
    
    // Логируем все темы и их позиции для отладки
    logInfo('=== All Themes ===');
    for (var theme in themes) {
      logInfo('ID: ${theme.id}, Name: ${theme.themeName}, ParentID: ${theme.parentId}, Position: ${theme.position}');
    }
    
    return themes;
  }

  Future<ThemeClass?> getThemeByName(String themeNameTranslation) async {
  final db = await database;
  final result = await db.query(
    tableTheme,
    where: 'theme_name_translation = ?',
    whereArgs: [themeNameTranslation],
  );

  if (result.isNotEmpty) {
    return ThemeClass.fromMap(result.first);
  } else {
    return null;
  }
}

Future<int> insertTheme(ThemeClass theme) async {
  final db = await database;
  return await db.insert(tableTheme, theme.toMap());
}


  void logInfo(String message) => print('📥 $message');
  void logSuccess(String message) => print('✅ $message');
  void logError(String message) => print('❌ $message');
}