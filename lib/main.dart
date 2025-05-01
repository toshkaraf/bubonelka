import 'package:bubonelka/classes/settings_and_state.dart';
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

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();try {
//     final data = await rootBundle.loadString('assets/csv/imperativ.csv');
//     print('CSV CONTENT:\n$data');
//   } catch (e) {
//     print('Ошибка загрузки imperativ.csv: $e');
//   }

//   try {
//     final data1 = await rootBundle.loadString('assets/csv/konjunktionen/index.csv');
//     print('CSV CONTENT:\n$data1');
//   } catch (e) {
//     print('Ошибка загрузки konjuktionen/index.csv: $e');
//   }

//   // Проверка первого запуска и инициализация БД
//   await initializeApp();

//   runApp(const MyApp());
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SettingsAndState.getInstance().loadSettings();

  print('🟢 main() запущен: старт приложения');

  try {
    await initializeApp();
    print('🟢 initializeApp() завершился успешно');
    runApp(const MyApp());
    print('🟢 runApp() вызван');
  } catch (e, stackTrace) {
    print('❌ Ошибка в main(): $e');
    print('❌ StackTrace: $stackTrace');
  }
}

Future<void> initializeApp() async {
  print('🟢 initializeApp() начат');

  try {
    final prefs = await SharedPreferences.getInstance();
    print('🟢 SharedPreferences получены');

    final dbHelper = DatabaseHelper();
    print('🟢 DatabaseHelper создан');

    final bool isFirstRun = prefs.getBool('isFirstRun') ?? true;
    print('🟢 isFirstRun = $isFirstRun');

    if (isFirstRun) {
      print('🟢 Первый запуск: загружаем начальные данные...');
      await dbHelper.loadInitialData();
      await prefs.setBool('isFirstRun', false);
      print('✅ Данные загружены при первом запуске');
    } else {
      print('🟢 Приложение уже запускалось ранее');
      bool hasData = await dbHelper.isInitialized();
      print('🟢 Проверка базы данных: hasData = $hasData');

      if (!hasData) {
        print('⚠️ База данных пуста, повторная загрузка данных...');
        await dbHelper.loadInitialData();
        print('✅ Данные успешно загружены повторно');
      } else {
        print('✅ Данные в базе данных найдены');
      }
    }

    print('🟢 initializeApp() завершён успешно');
  } catch (e, stackTrace) {
    print('❌ Ошибка внутри initializeApp(): $e');
    print('❌ StackTrace: $stackTrace');
    rethrow; // Обязательно прокидываем ошибку дальше
  }
}

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
        learningPageRoute: (context) => LearningPage(),
        chooseThemePageRoute: (context) => ChooseThemePage(),
        favoritePhrasesPage: (context) => FavoritePhrasesPage(),
        // playlistsListPage: (context) => PlaylistsListPage(),
      },
    );
  }
}
