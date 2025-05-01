import 'package:bubonelka/classes/phrase_card.dart';
import 'package:bubonelka/classes/theme.dart'; // исправил путь на актуальный

// Пути к CSV-файлам
const String csvFileOfCollection = 'assets/phrase_collection.csv';
const String csvFileOfCollectionNew = 'phrase_collection_new.csv';
const String csvFileReservCopy = 'reserve_collection_new.csv';

const double russianSpeachRate = 0.8;

// Общие константы
const String noPath = '';

// Названия и шаблоны
const String favoritePhrasesSet = 'Избранное';

// Экземпляр темы "Избранное"
final ThemeClass favoriteSet = ThemeClass(
  themeNameTranslation: favoritePhrasesSet,
  themeName: 'Favorites',
  fileName: '',
  numberOfRepetition: 0,
  parentId: -1,
  levels: ['A', 'B'],
);

// Для чтения и парсинга CSV
const String themeConstForCSV = 'Тема##';
const String playListConstForCSV = 'Плейлист##';
const int maxNumberOfThemesInPlaylist = 20;

// UI параметры
const double dividerWidth = 8.0;

// Заглушки для PhraseCard
final PhraseCard emptyPhraseCard = PhraseCard(
  themeName: 'EmptyCard',
  germanPhrases: ['Es gibt keine Phrasen mehr zu lernen! Wählen Sie neue Themen.'],
  translationPhrases: ['Фраз для изучения больше нет! Выбери новые темы.'],
  themeId: -1,
);

final PhraseCard neutralPhraseCard = PhraseCard(
  themeName: 'NeutralCard',
  germanPhrases: [''],
  translationPhrases: [''],
  themeId: -1,
);

// Настройки воспроизведения
const int delayBeforGermanPhraseInSeconds = 5;
const double speechRateTranslation = 0.6;

// Названия страниц
const String editPhrasePageName = 'Редактируем фразы';
const String createPhrasePageName = 'Добавляем фразы';
