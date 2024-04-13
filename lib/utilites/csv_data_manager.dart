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
          //         .remove(favoriteThemeName);
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
    // Map<String, List<PhraseCard>> phraseCardsMap = {
    //   favoritePhrasesSet: [],
    // };
    CollectionProvider.getInstance().mapOfThemes.clear();
    Map<String, List<PhraseCard>> totalCollection = {
      favoritePhrasesSet: [],
    };
    Map<String, ThemeClass> mapOfThemes = {};
    Map<String, List<String>> mapOfPlaylists = {};
    String currentThemeName = '';

    for (var row in csvData) {
      // Check if the row has enough data to create a PhraseCard object

      if (row[0] == playListConstForCSV) {
        String playlistName =
            row[1] != null && row[1].trim().isNotEmpty ? row[1] : '';
        List<String> playlist = [];
        for (int i = 2; i < row.length; i++) {
          if (row[i] != null && row[i].trim().isNotEmpty) {
            playlist.add(row[i]);
          }
        }
        mapOfPlaylists[playlistName] = playlist;
      } else if (row[0] == themeConstForCSV) {
        //create object Thema
        String themeNameTranslation =
            row[1] != null && row[1].trim().isNotEmpty ? row[1] : '';
        String themeNameGerman =
            row[2] != null && row[2].trim().isNotEmpty ? row[2] : '';
        int numberOfRepetition =
            row[3] != null && row[3].trim().isNotEmpty ? int.parse(row[3]) : 0;
        DateTime? timeOfLastRepetition =
            row[4] != null && row[4].trim().isNotEmpty
                ? DateTime.tryParse(row[4])
                : null;
        ThemeClass theme = ThemeClass(
            themeNameTranslation: themeNameTranslation,
            themeName: themeNameGerman,
            numberOfRepetition: numberOfRepetition,
            timeOfLastRepetition: timeOfLastRepetition);

        currentThemeName = themeNameTranslation;
        mapOfThemes[currentThemeName] = theme;
        totalCollection[currentThemeName] = [];
      } else {
        // Parse CSV data and create PhraseCard objects
        List<String> translationPhrases = [
          row[1] != null && row[1].trim().isNotEmpty ? row[1] : '',
          row[2] != null && row[2].trim().isNotEmpty ? row[2] : '',
          row[3] != null && row[3].trim().isNotEmpty ? row[3] : '',
        ];
        List<String> germanPhrases = [
          row[4] != null && row[4].trim().isNotEmpty ? row[4] : '',
          row[5] != null && row[5].trim().isNotEmpty ? row[5] : '',
          row[6] != null && row[6].trim().isNotEmpty ? row[6] : '',
        ];
        bool isActive = row[7] != null && row[7].trim().isNotEmpty
            ? bool.parse(row[7])
            : true;

        PhraseCard phraseCard = PhraseCard(
            themeNameTranslation: currentThemeName,
            translationPhrase: translationPhrases,
            germanPhrase: germanPhrases,
            isActive: isActive);

        // add Theme names and sort PhraseCards to dictionaries
        // if (!phraseCardsMap.containsKey(themeNameTranslation)) {
        //   phraseCardsMap[themeNameTranslation] = {};
        // }

        if (totalCollection.containsKey(currentThemeName)) {
          totalCollection[currentThemeName]!.add(phraseCard);
        } else {
          totalCollection[currentThemeName] = [
            phraseCard
          ]; // Создать новый список с PhraseCard и добавить его в totalCollection
        }
      }
    }

    if (isThisRestoreFromFile) {
      CollectionProvider.getInstance().mapOfThemes.clear();
      isThisRestoreFromFile = false;
    }
    CollectionProvider.getInstance().setTotalCollection(totalCollection);
    CollectionProvider.getInstance().printCollection(totalCollection);
    CollectionProvider.getInstance().mapOfThemes = mapOfThemes;
    CollectionProvider.getInstance().setMapOfPlaylists(mapOfPlaylists);
  }

  Future<void> uploadCsvData(String filePath) async {
    List<List<dynamic>> allCsvData = _convertDataToCsvData();
    print('загрузка' + allCsvData.toString());
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

  List<List<dynamic>> _convertDataToCsvData() {
    List<List<dynamic>> csvData = [];
    Map<String, List<PhraseCard>> totalCollection =
        CollectionProvider.getInstance().getTotalCollection();
    Map<String, ThemeClass> mapOfThemes =
        CollectionProvider.getInstance().themesMap;
    Map<String, List<String>> mapOfPlaylists =
        CollectionProvider.getInstance().playlistsMap;

    for (var key in mapOfPlaylists.keys) {
      var list = mapOfPlaylists[key];
      if (list != null) {
        csvData.add(
            [playListConstForCSV, key, ...list]); // Добавляем список напрямую
      }
    }

    for (var key in totalCollection.keys) {
      ThemeClass theme;
      if (key == favoritePhrasesSet) {
        theme = favoriteSet;
      } else {
        theme = mapOfThemes[key]!;
      }
      csvData.add([
        themeConstForCSV,
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
            phrase.isActive,
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
