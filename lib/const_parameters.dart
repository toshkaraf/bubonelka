import 'package:bubonelka/classes/phrase_card.dart';

const String csvFileOfCollection = 'assets/phrase_collection.csv';
const String csvFileOfCollectionNew = 'phrase_collection_new.csv';
const String csvFileOfThemes = 'themes.csv';
const String csvFileOfThemesNew = 'themes_new.csv';

const String noPath = '';

const String favoritePhrasesSet = 'Favoriten';

// for reading und parsing csv
const String themeConst = 'Тема##';

const dividerWidth = 8.0;

PhraseCard emptyPhraseCard = PhraseCard(
    themeNameTranslation: "Пустая карта",
    translationPhrase: List.filled(1, 'Фраз для изучения больше нет! Выбери новые темы.'),
    germanPhrase: List.filled(1, 'Es gibt keine Phrasen mehr zu lernen! Wählen Sie neue Themen.'));

PhraseCard neutralPhraseCard = PhraseCard(
    themeNameTranslation: "",
    translationPhrase: List.filled(1, ''),
    germanPhrase: List.filled(1, ''));
