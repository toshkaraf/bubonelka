// const_parameters.dart (обновлённый)
import 'package:bubonelka/classes/phrase_card.dart';
import 'package:bubonelka/classes/theme.dart';

// Пути к CSV-файлам
const String csvFileOfCollection = 'assets/phrase_collection.csv';
const String csvFileOfCollectionNew = 'phrase_collection_new.csv';
const String csvFileReservCopy = 'reserve_collection_new.csv';

// Общие константы
const String noPath = '';

// Названия и шаблоны
const String favoritePhrasesSet = 'Избранное';

// Экземпляр темы "Избранное"
ThemeClass favoriteSet = ThemeClass(
  themeNameTranslation: favoritePhrasesSet,
  themeName: '',
  fileName: '',
  numberOfRepetition: 0,
  parentId: -1,
  levels: ['A', 'B'],
);

// Для чтения и парсинга CSV
const String themeConstForCSV = 'Тема##';
const String playListConstForCSV = 'Плейлист##';
const int maxNumberOfThemesInPlaylist = 20;

// UI
const double dividerWidth = 8.0;

// Заглушка: пустая карта, если фраз не осталось
PhraseCard emptyPhraseCard = PhraseCard(
  themeName: 'EmptyCard',
  translationPhrases: [
    'Фраз для изучения больше нет! Выбери новые темы.',
  ],
  germanPhrases: [
    'Es gibt keine Phrasen mehr zu lernen! Wählen Sie neue Themen.',
  ],
  isActive: true,
  isDeleted: false,
  themeId: -1,
);

// Нейтральная карта-заполнитель
PhraseCard neutralPhraseCard = PhraseCard(
  themeName: 'NeutralCard',
  translationPhrases: [''],
  germanPhrases: [''],
  isActive: true,
  isDeleted: false,
  themeId: -1,
);

// Настройки воспроизведения
const int delayBeforGermanPhraseInSeconds = 5;
const double speechRateTranslation = 0.5;

// Названия страниц
const String editPhrasePageName = 'Редактируем фразы';
const String createPhrasePageName = 'Добавляем фразы';
