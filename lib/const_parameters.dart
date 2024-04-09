import 'package:bubonelka/classes/phrase_card.dart';
import 'package:bubonelka/classes/theme.dart';

const String csvFileOfCollection = 'assets/phrase_collection.csv';
const String csvFileOfCollectionNew = 'phrase_collection_new.csv';
const String csvFileReservCopy = 'reserve_collection_new.csv';

const String noPath = '';

const String favoritePhrasesSet = 'Избранное';
ThemeClass favoriteSet = ThemeClass(
    themeNameTranslation: favoritePhrasesSet,
    themeName: '',
    numberOfRepetition: 0);

// for reading und parsing csv
const String themeConstForCSV = 'Тема##';
const String playListConstForCSV = "Плейлист##";
const int maxNumberOfThemesInPlaylist = 20;

const dividerWidth = 8.0;

PhraseCard emptyPhraseCard = PhraseCard(
    themeNameTranslation: "Пустая карта",
    translationPhrase:
        List.filled(1, 'Фраз для изучения больше нет! Выбери новые темы.'),
    germanPhrase: List.filled(
        1, 'Es gibt keine Phrasen mehr zu lernen! Wählen Sie neue Themen.'),
    isActive: true);

PhraseCard neutralPhraseCard = PhraseCard(
    themeNameTranslation: "",
    translationPhrase: List.filled(1, ''),
    germanPhrase: List.filled(1, ''),
    isActive: true);

const int delayBeforGermanPhraseInSeconds = 5;

const String editPhrasePageName = 'Редактируем фразы';
const String createPhrasePageName = 'Добавляем фразы';
