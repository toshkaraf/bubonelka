import 'package:bubonelka/pages/choose_theme.dart';
import 'package:bubonelka/pages/favorite_page.dart';
import 'package:bubonelka/pages/learning_page.dart';
import 'package:bubonelka/pages/loading_screen.dart';
import 'package:bubonelka/pages/playlists_list%20_page.dart';
import 'package:bubonelka/pages/start_page.dart';
import 'package:bubonelka/pages/theme_list_page.dart';
import 'package:bubonelka/rutes.dart';
import 'package:bubonelka/utilites/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();try {
    final data = await rootBundle.loadString('assets/csv/imperativ.csv');
    print('CSV CONTENT:\n$data');
  } catch (e) {
    print('Ошибка загрузки imperativ.csv: $e');
  }

 
  try {
    final data1 = await rootBundle.loadString('assets/csv/konjunktionen/index.csv');
    print('CSV CONTENT:\n$data1');
  } catch (e) {
    print('Ошибка загрузки konjuktionen/index.csv: $e');
  }

  await initializeApp();
  // Проверка первого запуска и инициализация БД
  await initializeApp();

  runApp(const MyApp());
}

Future<void> initializeApp() async {
  final prefs = await SharedPreferences.getInstance();
  final bool isFirstRun = prefs.getBool('isFirstRun') ?? true;

  final dbHelper = DatabaseHelper();

  if (isFirstRun) {
    // Загружаем данные из CSV в БД при первом запуске
    print('Первый запуск: загрузка данных из CSV...');
    await dbHelper.loadInitialData();

    // Отмечаем, что первый запуск прошел
    await prefs.setBool('isFirstRun', false);
  } else {
    print('Приложение уже инициализировано ранее');
    // Проверка наличия данных в БД
    bool hasData = await dbHelper.isInitialized();
    if (!hasData) {
      // Если по какой-то причине данных нет, загружаем их снова
      print('Данных в БД нет, повторная загрузка...');
      await dbHelper.loadInitialData();
    }
  }
}

// void main() {
//   runApp(const MyApp());
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoadingScreen(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        startRoute: (context) => StartPage(),
        // themeLiЫstPageRoute: (context) => ThemesListPage(),
        // learningPageRoute: (context) => LearningPage(),
        // chooseThemePageRoute: (context) => ChooseThemePage(),
        // favoritePhrasesPage: (context) => FavoritePhrasesPage(),
        // playlistsListPage: (context) => PlaylistsListPage(),
      },
    );
  }
}
