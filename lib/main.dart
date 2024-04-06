import 'package:bubonelka/pages/choose_theme.dart';
import 'package:bubonelka/pages/learning_page.dart';
import 'package:bubonelka/pages/loading_screen.dart';
import 'package:bubonelka/pages/start_page.dart';
import 'package:bubonelka/pages/theme_list_page.dart';
import 'package:bubonelka/rutes.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoadingScreen(),
      routes: {
        startRoute: (context) => StartPage(),
        themeListPageRoute: (context) => ThemesListPage(),
        learningPageRoute: (context) => LearningPage(),
        chooseThemePageRoute: (context) => ChooseThemePage(),
      },
    );
  }
}
