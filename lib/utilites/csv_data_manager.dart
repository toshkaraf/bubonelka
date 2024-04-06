import 'dart:io';
import 'package:bubonelka/classes/collection_provider.dart';
import 'package:bubonelka/classes/phrase_card.dart';
import 'package:bubonelka/classes/theme.dart';
import 'package:csv/csv.dart';
import 'package:bubonelka/const_parameters.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class CsvDataManager {
  factory CsvDataManager() => getInstance();

  CsvDataManager._privateConstructor();

  static CsvDataManager? _instance;

  static CsvDataManager getInstance() {
    _instance ??= CsvDataManager._privateConstructor();
    return _instance!;
  }

  // SettingsAndState settingsAndState = SettingsAndState();
  bool isThisRestoreFromFile = false;
  String csvPhraseString = '';

  Future<Map<String, Set<PhraseCard>>> loadDataFromFile(String filePath) async {
    Map<String, Set<PhraseCard>> phraseCardsMap = {};

    // when we do not recieve filePath means that we need to do usual initial data dawnload.
    // not data saved by user himself
    if (filePath != noPath) {
      isThisRestoreFromFile = true;
    }

    try {
      if (filePath == noPath) {
        Directory documentsDirectory = await getApplicationDocumentsDirectory();
        filePath = '${documentsDirectory.path}/$csvFileOfCollectionNew';
      }

      csvPhraseString = '';
      File file = File(filePath);

      // Восстановление из основного файла текущих данных или из резервной копии, если основной файл пуст
      if (await file.exists()) {
        try {
          csvPhraseString = await file.readAsString();
          // if (csvPhraseString.isEmpty) {
          //   File reserveCopyFile = File(
          //       '${(await getApplicationDocumentsDirectory()).path}/$reserveCopyFileName');
          //   if (await reserveCopyFile.exists()) {
          //     csvPhraseString = await reserveCopyFile.readAsString();
          //     settingsAndState.listOfAllDictionariesNames
          //         .remove(favoriteDictionaryName);
          //     // restoreDataFromReseveCopy();
          //   }
          // }
        } catch (e) {
          print('$e');

          // // TODO exceptions
          // if (e == 'Ошибка згрузки данных. Возможно, результаты последней сессии утрачены!')
          // restoreDataFromReseveCopy();
        }
      } else {
        // if it is a first time run of app, get data from initial data file
        csvPhraseString = await rootBundle.loadString(csvFileOfCollection);
      }

      CsvToListConverter converter = const CsvToListConverter(
        fieldDelimiter: ';',
        eol: '\n',
        shouldParseNumbers: false,
      );
      print('Загрузка' + csvPhraseString);

      List<List<dynamic>> csvData = converter.convert(csvPhraseString);
      _populatePhraseCardMap(csvData);
    } catch (e) {
      print('Error loading CSV data: $e');
    }

    return phraseCardsMap;
  }

  void _populatePhraseCardMap(List<List<dynamic>> csvData) {
    // ensure favorite folder as empty
    Map<String, Set<PhraseCard>> phraseCardsMap = {
      favoritePhrasesSet: {},
    };
    CollectionProvider.getInstance().mapOfThemes.clear();
    Map<String, List<PhraseCard>> totalCollection = {};
    Map<String, ThemeClass> mapOfThemes = {};
    List<String> translationPhrases = List.filled(3, '');
    List<String> germanPhrases = List.filled(3, '');

    for (var row in csvData) {
      // Check if the row has enough data to create a PhraseCard object
      if (row.length >= 7) {
        if (row[0] == themeConst) {
          //create object Thema
          String themeNameTranslation =
              row[1] != null && row[1].trim().isNotEmpty ? row[1] : '';
          String themeNameGerman =
              row[2] != null && row[2].trim().isNotEmpty ? row[2] : '';
          int numberOfRepetition = row[3] != null && row[3].trim().isNotEmpty
              ? int.parse(row[3])
              : 0;
          DateTime? timeOfLastRepetition =
              row[4] != null && row[4].trim().isNotEmpty
                  ? DateTime.tryParse(row[4])
                  : null;
          ThemeClass theme = ThemeClass(
              themeNameTranslation: themeNameTranslation,
              themeName: themeNameGerman,
              numberOfRepetition: numberOfRepetition,
              timeOfLastRepetition: timeOfLastRepetition);

          mapOfThemes[theme.themeNameTranslation] = theme;
          totalCollection[theme.themeNameTranslation] = [];
        } else {
          // Parse CSV data and create PhraseCard objects
          String themeNameTranslation =
              row[0] != null && row[0].trim().isNotEmpty ? row[0] : '';
          translationPhrases[0] =
              row[1] != null && row[1].trim().isNotEmpty ? row[1] : '';
          translationPhrases[1] =
              row[2] != null && row[2].trim().isNotEmpty ? row[2] : '';
          translationPhrases[2] =
              row[3] != null && row[3].trim().isNotEmpty ? row[3] : '';
          germanPhrases[0] =
              row[4] != null && row[4].trim().isNotEmpty ? row[4] : '';
          germanPhrases[1] =
              row[5] != null && row[5].trim().isNotEmpty ? row[5] : '';
          germanPhrases[2] =
              row[6] != null && row[6].trim().isNotEmpty ? row[6] : '';

          PhraseCard phraseCard = PhraseCard(
              themeNameTranslation: themeNameTranslation,
              translationPhrase: translationPhrases,
              germanPhrase: germanPhrases);

          // add dictionary names and sort PhraseCards to dictionaries
          // if (!phraseCardsMap.containsKey(themeNameTranslation)) {
          //   phraseCardsMap[themeNameTranslation] = {};
          // }

          if (phraseCardsMap.containsKey(themeNameTranslation)) {
            phraseCardsMap[themeNameTranslation]!.add(phraseCard);
          } else {
            phraseCardsMap[themeNameTranslation] = {phraseCard};
          }
        }
      } else {
        // Handle the case when the row doesn't have enough data for a PhraseCard object
        print('Error: Invalid CSV row data: $row');
      }
    }
    if (isThisRestoreFromFile) {
      CollectionProvider.getInstance().mapOfThemes.clear();
      isThisRestoreFromFile = false;
    }
    CollectionProvider.getInstance().totalCollection = totalCollection;
    CollectionProvider.getInstance().mapOfThemes = mapOfThemes;
  }

  Future<void> uploadCsvData(
      Map<String, List<PhraseCard>> collectionOfPhraseCard,
      String filePath) async {
    List<List<dynamic>> allCsvData =
        _convertSetToCsvData(collectionOfPhraseCard);
    await _uploadAllCsvData(allCsvData, filePath);

    // // Проверяем, нужно ли сохранить в резервную копию (сохраняется каждый второй раз вызова метода )
    // settingsAndState.reserveUploadCount++;
    // if (settingsAndState.reserveUploadCount == 20) {
    //   settingsAndState.reserveUploadCount = 0;
    //   try {
    //     Directory documentsDirectory = await getApplicationDocumentsDirectory();
    //     String reserveCopyFilePath =
    //         '${documentsDirectory.path}/$reserveCopyFileName';
    //     await _uploadAllCsvData(allCsvData, reserveCopyFilePath);
    //     print('Данные сохранены в резервную копию: $reserveCopyFilePath');
    //   } catch (e) {
    //     print('Ошибка сохранения данных в резервную копию: $e');
    //   }
    // }
  }

  List<List<dynamic>> _convertSetToCsvData(
      Map<String, List<PhraseCard>> totalCollection) {
    List<List<dynamic>> csvData = [];
    Map<String, ThemeClass> mapOfThemes =
        CollectionProvider.getInstance().themesMap;
    for (var key in totalCollection.keys) {
      ThemeClass theme = mapOfThemes[key]!;

      csvData.add([
        themeConst,
        theme.themeNameTranslation,
        theme.themeName,
        theme.numberOfRepetition,
        theme.timeOfLastRepetition.toString()
      ]);

      var list = totalCollection[key];
      if (list != null) {
        for (var phrase in list) {
          csvData.add([
            theme.themeNameTranslation,
            phrase.translationPhrase[0],
            phrase.translationPhrase[1],
            phrase.translationPhrase[2],
            phrase.germanPhrase[0],
            phrase.germanPhrase[1],
            phrase.germanPhrase[2],
          ]);
        }
      }
    }
    return csvData;
  }

  Future<void> _uploadAllCsvData(
      List<List<dynamic>> csvData, String filePath) async {
    // Convert the CSV data to string with ';' as the field delimiter
    String csvPhraseString = const ListToCsvConverter(
      fieldDelimiter: ';',
      eol: '\n',
    ).convert(csvData);
    print('Выгрузка' + csvPhraseString);

    // Get the documents directory
    if (filePath == noPath) {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      filePath = '${documentsDirectory.path}/$csvFileOfCollectionNew';
    }
    // Write the CSV data to a file
    File file = File(filePath);
    await file.writeAsString(csvPhraseString);
  }
}
