import 'package:bubonelka/pages/theme_page.dart';
import 'package:flutter/material.dart';
import 'package:bubonelka/utilites/database_helper.dart';
import 'package:bubonelka/classes/theme.dart';
import 'package:bubonelka/classes/settings_and_state.dart';
import 'package:bubonelka/rutes.dart';
import 'package:bubonelka/pages/learning_page.dart';

class RepeatRecommendedPage extends StatefulWidget {
  const RepeatRecommendedPage({super.key});

  @override
  State<RepeatRecommendedPage> createState() => _RepeatRecommendedPageState();
}

class _RepeatRecommendedPageState extends State<RepeatRecommendedPage> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<ThemeClass> recommendedThemes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecommendedThemes();
  }

  Future<void> _loadRecommendedThemes() async {
    final dueThemes = await dbHelper.getDueThemes();
    setState(() {
      recommendedThemes = dueThemes; // Никакой лишней фильтрации и сортировки
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Темы для повторения'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : recommendedThemes.isEmpty
              ? const Center(child: Text('Нет тем для повторения на сегодня'))
              : ListView.builder(
                  itemCount: recommendedThemes.length,
                  itemBuilder: (context, index) {
                    final theme = recommendedThemes[index];
                    return ListTile(
                      leading: Container(
                        width: 48,
                        alignment: Alignment.center,
                        child: theme.currentStage > 0
                            ? Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: theme.stageColor,
                                  shape: BoxShape.circle,
                                ),
                              )
                            : null,
                      ),
                      title: Text(
                        theme.themeName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        theme.themeNameTranslation,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.play_arrow, color: Colors.green),
                        onPressed: () => _startSingleThemeLearning(theme),
                      ),
                      onTap: () => _openThemePage(theme),
                    );
                  },
                ),
      floatingActionButton: recommendedThemes.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: SizedBox(
                width: 200,
                child: FloatingActionButton.extended(
                  heroTag: 'start_learning_hero_recommended',
                  onPressed: _startRepeatAll,
                  label: const Text('Повторить все'),
                  icon: const Icon(Icons.play_circle_fill),
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _startSingleThemeLearning(ThemeClass theme) {
    SettingsAndState.getInstance().chosenThemes = [theme.themeNameTranslation];
    Navigator.pushNamed(
      context,
      learningPageRoute,
      arguments: {
        'theme': theme,
        'mode': LearningMode.repeatRecommended,
      },
    );
  }

  void _startRepeatAll() {
    SettingsAndState.getInstance().chosenThemes =
        recommendedThemes.map((t) => t.themeNameTranslation).toList();

    Navigator.pushNamed(
      context,
      learningPageRoute,
      arguments: {
        'theme': recommendedThemes.first,
        'mode': LearningMode.repeatRecommended,
        'themeList': recommendedThemes,
      },
    );
  }

  void _openThemePage(ThemeClass theme) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ThemePage(theme: theme),
      ),
    );
  }
}
