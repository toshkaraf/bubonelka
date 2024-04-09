import 'package:bubonelka/classes/phrase_card.dart';
import 'package:bubonelka/classes/theme.dart';
import 'package:bubonelka/const_parameters.dart';
import 'package:bubonelka/utilites/csv_data_manager.dart';

class CollectionProvider {
  static final CollectionProvider _instance = CollectionProvider._internal();

  CollectionProvider._internal();

  static CollectionProvider getInstance() {
    return _instance;
  }

  Map<String, List<PhraseCard>> totalCollection = {};
  Map<String, ThemeClass> mapOfThemes = {};
  List<String> _chosenThemes = [];
  Map<String, List<String>> mapOfPlaylists = {};

  Future<void> initializeCollectionProvider(String filePath) async {
    try {
      await CsvDataManager.getInstance().loadDataFromFile(filePath);
      printCollection(totalCollection);
    } on Exception catch (e) {
      // Перехватываем исключение и пробрасываем его дальше
      throw Exception('Проброшено из вызывающего метода: $e');
    } catch (e) {
      print('Ошибка при инициализации коллекции: $e');
    }
  }

  void setTotalCollection(Map<String, List<PhraseCard>> totalCollection) {
    this.totalCollection = totalCollection;
  }

  Map<String, List<PhraseCard>> getTotalCollection() {
    return totalCollection;
  }

  List<PhraseCard>? getListOfPhrasesForTheme(String theme) {
    return totalCollection[theme];
  }

  // Геттер для mapOfThemes
  Map<String, ThemeClass> get themesMap => mapOfThemes;

  // Сеттер для mapOfThemes
  set themesMap(Map<String, ThemeClass> value) => mapOfThemes = value;

  List<String> getListOfThemesNames() {
    return mapOfThemes.keys.toList();
  }

  Map<String, List<String>> get playlistsMap => mapOfPlaylists;

  void addToPlaylists(String nameOfPlaylist, List<String> themesNames) {
    mapOfPlaylists[nameOfPlaylist] = themesNames;
  }

  void deleteThemeOutOfPlaylist(String nameOfPlaylist, String themeName) {
    mapOfPlaylists[nameOfPlaylist]?.remove(themeName);
  }

  List<String> get chosenThemes => _chosenThemes;

  set chosenThemes(List<String> themes) {
    _chosenThemes = themes;
  }

  void printCollection(Map<String, List<PhraseCard>> totalCollection) {
    totalCollection.forEach((theme, phraseCards) {
      print('Theme: $theme');
      phraseCards.forEach((phraseCard) {
        phraseCard.printPhraseCard();
        print('---');
      });
    });
  }

  void deletePhraseCard(PhraseCard phraseCard) {
    totalCollection[phraseCard.themeNameTranslation]!.remove(phraseCard);
  }

  void replacePhraseCard(PhraseCard oldPhraseCard, PhraseCard newPhraseCard) {
    if (oldPhraseCard != neutralPhraseCard) {
      int index = totalCollection[newPhraseCard.themeNameTranslation]!
          .indexOf(oldPhraseCard);
      if (index != -1) {
        totalCollection[newPhraseCard.themeNameTranslation]![index] =
            newPhraseCard;
      }
    } else {
      totalCollection[newPhraseCard.themeNameTranslation]!.add(newPhraseCard);
    }
  }

  void addNewPhraseCard(PhraseCard phraseCard) {
    totalCollection[phraseCard.themeNameTranslation]!.add(phraseCard);
  }

  void addNewTheme(String themeNameTranslation, String themeName) {
    mapOfThemes[themeNameTranslation] = ThemeClass(
      themeNameTranslation: themeNameTranslation,
      themeName: themeName,
      numberOfRepetition: 0,
    );
  }

  void upgradeStatisticForTheme(String themeNameTranslation) {
    mapOfThemes[themeNameTranslation]!.numberOfRepetition++;
  }

  void deleteTheme(String themeNameTranslation) {
    mapOfThemes.remove(themeNameTranslation);
  }

  void deleteplaylist(String themeNameTranslation) {
    mapOfPlaylists.remove(themeNameTranslation);
  }

  void setChosenThemesFromPlaylist(String playlistName) {
    chosenThemes = mapOfPlaylists[playlistName] ?? [];
  }
}
