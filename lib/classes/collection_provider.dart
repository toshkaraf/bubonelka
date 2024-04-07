import 'package:bubonelka/classes/phrase_card.dart';
import 'package:bubonelka/classes/theme.dart';
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
  List<String> _playlists = [];

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

  List<PhraseCard> getListOfPhrasesForTheme(String theme) {
    return totalCollection[theme]!;
  }

  // Геттер для mapOfThemes
  Map<String, ThemeClass> get themesMap => mapOfThemes;

  // Сеттер для mapOfThemes
  set themesMap(Map<String, ThemeClass> value) => mapOfThemes = value;

  List<String> getListOfThemesNames() {
    return mapOfThemes.keys.toList();
  }

  List<String> get playlists => _playlists;

  set playlists(List<String> playlists) {
    _playlists = playlists;
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
}
