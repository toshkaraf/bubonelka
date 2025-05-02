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
    final allThemes = await dbHelper.getAllThemes();
    final now = DateTime.now();

    final readyThemes = allThemes.where((theme) {
      if (theme.timeOfLastRepetition == null) return true; // Никогда не повторяли — готово
      final lastDate = DateTime.tryParse(theme.timeOfLastRepetition!);
      if (lastDate == null) return true;
      final nextDate = lastDate.add(
        Duration(days: _getIntervalForTheme(theme.numberOfRepetition)),
      );
      return now.isAfter(nextDate);
    }).toList();

    setState(() {
      recommendedThemes = readyThemes;
      _isLoading = false;
    });
  }

  int _getIntervalForTheme(int numberOfRepetitions) {
    // Можно адаптировать интервалы здесь по твоей логике
    if (numberOfRepetitions <= 1) return 1;
    if (numberOfRepetitions == 2) return 3;
    if (numberOfRepetitions == 3) return 7;
    if (numberOfRepetitions == 4) return 14;
    return 30;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Рекомендованные темы для повторения'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : recommendedThemes.isEmpty
              ? const Center(child: Text('Нет тем для повторения на сегодня'))
              : ListView.builder(
                  itemCount: recommendedThemes.length,
                  itemBuilder: (context, index) {
                    final theme = recommendedThemes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(theme.themeName,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(theme.themeNameTranslation,
                                style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 8),
                            _buildProgressBar(theme),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.play_arrow, color: Colors.green),
                          onPressed: () => _startSingleThemeLearning(theme),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: recommendedThemes.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _startRepeatAll,
              icon: const Icon(Icons.play_circle_fill),
              label: const Text('Повторить все'),
            )
          : null,
    );
  }

  Widget _buildProgressBar(ThemeClass theme) {
    final progress = (theme.numberOfRepetition / 5).clamp(0.0, 1.0);
    final progressText = 'Прогресс повторений: ${theme.numberOfRepetition} / 5';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(value: progress),
        const SizedBox(height: 4),
        Text(progressText, style: const TextStyle(fontSize: 12)),
      ],
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

    // Здесь передаем весь список recommendedThemes напрямую
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
}
